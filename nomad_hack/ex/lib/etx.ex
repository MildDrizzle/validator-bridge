defmodule ETX do
    import Nx.Defn

    @zero Nx.tensor(0.0)

    #This feeds 400 images, batches 20*5
    @batch_size 20
    @batches 20
    @total_input (@batch_size * @batches)

    #needs to be same as cosine_label
    @vector_dims 25

    @batch_shape_img [@batch_size, 1, 32, 32]
    @batch_shape_labels [@batch_size, @vector_dims]

    @epochs 30

    @total_labels 2

    def axon do
        model = 
        Axon.input({nil, 1, 32, 32})
        |> Axon.conv(16, kernel_size: {3, 3}, padding: [{1,1},{1,1}], activation: :relu)
        |> Axon.max_pool(kernel_size: 2)
        |> Axon.conv(8, kernel_size: {3, 3}, padding: [{2,2},{2,2}], activation: :relu)
        |> Axon.max_pool(kernel_size: 2)
        |> Axon.conv(1, kernel_size: {3, 3}, padding: [{2,2},{2,2}], activation: :relu)
        |> Axon.max_pool(kernel_size: 2)
    end

    #we can change the amount of neurons here
    def init_weights() do
        w1 = Axon.Initializers.glorot_uniform(shape: {16, 1, 3, 3})
        b1 = Axon.Initializers.zeros(shape: {16})
        w2 = Axon.Initializers.glorot_uniform(shape: {8, 16, 3, 3})
        b2 = Axon.Initializers.zeros(shape: {8})
        w3 = Axon.Initializers.glorot_uniform(shape: {1, 8, 3, 3})
        b3 = Axon.Initializers.zeros(shape: {1})
        binding() |> Enum.into(%{})
    end

    #we can change layers or network here
    defn predict(w, input) do
        input
        |> Axon.Layers.conv(w.w1, w.b1, padding: [{1,1},{1,1}])
        |> Axon.Activations.relu()
        |> Axon.Layers.max_pool(kernel_size: 2)
        |> Axon.Layers.conv(w.w2, w.b2, padding: [{2,2},{2,2}])
        |> Axon.Activations.relu()
        |> Axon.Layers.max_pool(kernel_size: 2)
        |> Axon.Layers.conv(w.w3, w.b3, padding: [{2,2},{2,2}])
        |> Axon.Activations.relu()
        |> Axon.Layers.max_pool(kernel_size: 2)
    end

    #our forward pass and loss
    defn objective(w, batch_images, batch_labels) do
        preds = predict(w, batch_images)
        |> Nx.reshape({Nx.axis_size(batch_images, 0), Nx.axis_size(batch_labels, 1)})
        loss = Nx.sum(1 - CosineLabel.cosine_similarity(preds, batch_labels)) / Nx.axis_size(preds, 0)
        {preds, loss}
    end

    #compute our forward and backwards pass
    defn update(m, batch_images, batch_labels, update_fn) do
        w = m.w
        {{preds, loss}, gw} = value_and_grad(w, &objective(&1, batch_images, batch_labels), &elem(&1, 1))
        {scaled_updates, optimizer_state} = update_fn.(gw, m.optimizer_state, w)
        w = Axon.Updates.apply_updates(w, scaled_updates)

        avg_loss = m.loss + (loss * Nx.axis_size(batch_images, 0)) / Nx.axis_size(batch_images, 0)

        %{m | w: w, optimizer_state: optimizer_state, loss: avg_loss}
    end

    #train 1 epoch passing each minibatch through network
    defn train_epoch(m, imgs, labels, update_fn) do
        #batches = @batches - 1
        #{_, m, _, _} = while {batches, m, imgs, labels}, Nx.greater_equal(batches,0) do
            #img_slice = Nx.slice(imgs, [@batch_size*batches,0,0,0], @batch_shape_img)
            #label_slice = Nx.slice(labels, [@batch_size*batches,0], @batch_shape_labels)
            m = update(m, imgs, labels, update_fn)
            #{batches - 1, m, imgs, labels}
        #end
        #m
    end

    #init model + train all epochs
    def train(imgs, labels) do
        w = init_weights()
        {init_fn, update_fn} = Axon.Optimizers.adamw(0.01, decay: 0.01)
        optimizer_state = init_fn.(w)
        m = %{optimizer_state: optimizer_state, w: w, loss: @zero}

        Enum.reduce(1..@epochs, m, fn(_, m) ->
            m = %{m | loss: @zero}
            train_epoch(m, imgs, labels, update_fn)
        end)
    end

    #generate our models
    def go() do
        Nx.Defn.global_default_options(compiler: EXLA, client: :host)

        magic_labels = CosineLabel.generate_label_vectors(@total_labels)

        {train, _test} = ETX.load()

        by_label = train
        |> Enum.into(%{}, fn{label, set}->
            {label, Enum.take(Enum.shuffle(set), @total_input)}
        end)

        models = Enum.into(0..(@total_labels-1), %{}, fn(n)->
            by_label = by_label[n]
            IO.inspect {by_label, n}
            label_count = length(by_label)
            imgs = by_label
            |> Enum.reduce("", & &2 <> Nx.to_binary(&1.tensor))
            |> Nx.from_binary({:u, 8})
            |> Nx.reshape({label_count, 1, 32, 32})
            |> Nx.divide(255)

            label = magic_labels[n]
            labels = Enum.map(1..label_count, fn(_)-> Nx.to_flat_list(label) end)
            |> Nx.tensor()

            m = train(imgs, labels)
            IO.inspect {:trained, n, Nx.to_number(m.loss)}
            {n, m}
        end)

        {models, magic_labels}
    end

    #test models
    def test(m, magic_labels) do
        Nx.Defn.global_default_options(compiler: EXLA, client: :host)

        {train, test} = ETX.load()
        train_acc = Enum.map(0..(@total_labels-1), fn(idx)->
            images = train[idx]
            correct = test_1(images, m, magic_labels)
            {idx, correct, length(images), Float.round(correct/length(images), 3)}
        end)
        test_acc = Enum.map(0..(@total_labels-1), fn(idx)->
            images = test[idx]
            if images != nil do
                correct = test_1(images, m, magic_labels)
                {idx, correct, length(images), Float.round(correct/length(images), 3)}
            end
        end) |> Enum.filter(& &1)
        {train_acc, test_acc}
    end

    def test_1(images, m, magic_labels) do
        imgs = images
        |> Enum.reduce("", & &2 <> Nx.to_binary(&1.tensor))
        |> Nx.from_binary({:u, 8})
        |> Nx.reshape({length(images), 1, 32, 32})
        |> Nx.divide(255)

        labels = Enum.map(images, fn(%{label: d})->
            Nx.to_flat_list(magic_labels[d])
        end)
        |> Nx.tensor()

        loss_list = Enum.map(0..(@total_labels-1), fn(idx)->
            w = m[idx].w
            preds = predict(w, imgs)
            |> Nx.reshape({length(images), @vector_dims})
            CosineLabel.cosine_similarity(preds, labels)
        end)

        loss = Nx.stack(loss_list)
        |> Nx.transpose()
        |> Nx.argsort(axis: 1)

        preds = Nx.slice(loss, [0,@total_labels], [length(images),1])
        |> Nx.to_flat_list()
        correct = Enum.reduce(Enum.zip(images, preds), 0, fn({%{label: d}, pred}, acc)->
            cond do
                #correct
                d == pred -> acc + 1
                #incorrect
                true -> acc
            end
        end)
        IO.puts correct
        correct
    end

    def load() do
        cached = :persistent_term.get(:nomad_cached, false)
        if !cached do
            tx11600 = File.read!("../11600_tx_json") |> JSX.decode!(labels: :atom)
            #tx1558 = tx11600 |> Enum.filter(& &1.input =~ "0x928bc4b2000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000d1")
            tx1558 = tx11600 |> Enum.filter(& byte_size(&1.input)<=1024)
            tx1558 = Enum.map(tx1558, & Map.put(&1,:tensor, String.pad_trailing(&1.input, 1024, <<0>>) |> Nx.from_binary({:u,8}) |> Nx.reshape({32,32}) ))
            bad76 = File.read!("../bad_76_json") |> JSX.decode!(labels: :atom)
            bad76 = Enum.map(bad76, & Map.put(&1,:tensor, String.pad_trailing(&1.input, 1024, <<0>>) |> Nx.from_binary({:u,8}) |> Nx.reshape({32,32}) ))
            #586
            
            pure = tx1558 -- bad76
            label_0 = Enum.map(pure, & &1.hash)
            label_1 = Enum.map(bad76, & &1.hash)

            clean = Enum.shuffle(pure) |> Enum.take(155)
            clean = Enum.shuffle(pure) |> Enum.take(840)
            bad = Enum.shuffle(bad76) |> Enum.take(7)
            bad = Enum.shuffle(bad76) |> Enum.take(14)

            fn_label = fn(hash) ->
                if hash in label_0 do 0 else 1 end
            end

            train = ((tx1558--clean)--bad)
            |> Enum.map(& Map.put(&1,:label,fn_label.(&1.hash))) 
            |> Enum.group_by(& &1.label)
            IO.inspect Map.keys(train)

            test = (clean ++ bad)
            |> Enum.map(& Map.put(&1,:label,fn_label.(&1.hash))) 
            |> Enum.group_by(& &1.label)
            IO.inspect Map.keys(test)

            cached = {train, test}
            :persistent_term.put(:nomad_cached, cached)
            cached
        else
            cached
        end
    end
end
