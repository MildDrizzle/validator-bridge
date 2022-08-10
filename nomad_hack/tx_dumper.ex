agg = Enum.map(0..16, fn(idx)->
    IO.inspect idx

    #url = "https://api.etherscan.io/api?module=account&action=tokentx&address=0x88a69b4e698a4b090df6cf5bd7b2d47325ad30a3&startblock=0&endblock=99999999&page=#{idx}&offset=100&sort=desc&apikey=87JMHVYUHIIYT2EPB5G28FE2P2V7AMSWZX"
    
    url = "https://endpoints.omniatech.io/v1/eth/ropsten/0c076cf7e65b4b9e91f66ebd83dd70da?module=account&action=tokentx&address=0x88a69b4e698a4b090df6cf5bd7b2d47325ad30a3&startblock=0&endblock=99999999&page=#{idx}&offset=100&sort=desc&apikey=87JMHVYUHIIYT2EPB5G28FE2P2V7AMSWZX"

    {:ok, %{body: body}} = :comsat_http.get(url)
    %{message: "OK", result: r} = JSX.decode!(body, labels: :atom)
    r
end) |> List.flatten()

agg2 = Enum.map(agg, fn(m)->
    IO.inspect Process.get(:cnt, 0)
    Process.put(:cnt, Process.get(:cnt, 0) + 1)
    
    #url = "https://api.etherscan.io/api?module=proxy&action=eth_getTransactionByHash&txhash=#{m.hash}&apikey=87JMHVYUHIIYT2EPB5G28FE2P2V7AMSWZX"
    
    url = "https://endpoints.omniatech.io/v1/eth/ropsten/0c076cf7e65b4b9e91f66ebd83dd70da?module=proxy&action=eth_getTransactionByHash&txhash=#{m.hash}&apikey=87JMHVYUHIIYT2EPB5G28FE2P2V7AMSWZX"
    
    {:ok, %{body: body}} = :comsat_http.get(url)
    %{result: r} = JSX.decode!(body, labels: :atom)
    m = Map.put(m, :input, r.input)
    mm = :persistent_term.get(:m, [])
    :persistent_term.put(:m, mm++[m])
    m
end)

malicious2 = Enum.filter agg2, & &1.to in ["0x56d8b635a7c88fd1104d23d632af40c1c3aac4e3", "0xBF293D5138a2a1BA407B43672643434C43827179", "0xb5c55f76f90cc528b2609109ca14d8d84593590e"]

File.write!("11600_tx_json", JSX.encode!(agg2))
File.write!("bad_76_json", JSX.encode!(malicious2))