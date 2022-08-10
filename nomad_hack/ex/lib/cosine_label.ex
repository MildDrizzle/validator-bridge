defmodule CosineLabel do
  import Nx.Defn

  #adjust vec_size and sim
  @vec_size 25
  @sim 0.50
  @sample_size 1_000_000

  Nx.Defn.global_default_options(compiler: EXLA, client: :host)

  # Set XLA_FLAGS=—xla_force_host_platform_device_count={num}
  # JIT and target “devices” separately

  defn gen_vec() do
    vec = Nx.random_normal({@vec_size})
    Nx.power(Nx.power(vec, 2) / Nx.sum(Nx.power(vec, 2)), 0.5)
  end

  defn gen_vec_large() do
    vec = Nx.random_normal({@sample_size, @vec_size})
    Nx.power(Nx.power(vec, 2) / Nx.sum(Nx.power(vec, 2)), 0.5)
  end

  defn cosine_similarity(x1, x2) do
    dim = [1]
    eps = 0.000001
    w12 = Nx.sum(x1 * x2, axes: [1])
    w1 = Nx.sum(x1 * x1, axes: [1])
    w2 = Nx.sum(x2 * x2, axes: [1])
    n12 = Nx.sqrt(Nx.max((w1 * w2), eps*eps))
    w12 / n12
  end

  defn next_label_vector(labels) do
    vec = CosineLabel.gen_vec_large()
    label_count = Nx.axis_size(labels, 0)
    v1 = Nx.reshape(vec, {@sample_size, 1, @vec_size})
    |> Nx.tile([1, label_count])
    |> Nx.reshape({@sample_size*label_count, @vec_size})
    v2 = Nx.tile(labels, [@sample_size, 1])
    sim = cosine_similarity(v1,v2)
    |> Nx.reshape({@sample_size, label_count})
    s = sim >= @sim
    sum = Nx.sum(s, axes: [1])
    best_idx = Nx.argmin(sum)
    if sum[best_idx] == 0 do
        vec[best_idx]
    end
  end

  defp generate_label_vectors_1(labels, vec_num) do
    vec = next_label_vector(labels)
    labels = if Nx.to_number(Nx.any(vec)) == 1 do
        IO.puts "found vector #{Nx.axis_size(labels,0)+1}"
        Nx.concatenate([labels, Nx.new_axis(vec, 0)])
    else labels end
    if Nx.axis_size(labels, 0) < vec_num do
        generate_label_vectors_1(labels, vec_num)
    else
        labels
    end
  end

  def generate_label_vectors(vec_num) do
    labels = Nx.broadcast(gen_vec(), {1, @vec_size})
    labels = generate_label_vectors_1(labels, vec_num)
    correctness(labels)
    labels
  end

  def correctness(labels) do
    size = Nx.axis_size(labels, 0) - 1
    [] = Enum.map(0..size, fn(idx)->
        label = labels[idx]
        sim = Enum.map(0..size, fn(idx2)->
            if idx != idx2 do
                cosine_similarity(Nx.new_axis(label, 0), Nx.new_axis(labels[idx2], 0))
            end
        end) |> Enum.filter(& &1)
        [] = Enum.filter(sim, & Nx.to_number(&1[0]) >= @sim)
    end) |> List.flatten()
  end
end
