using System.Collections.Generic;

namespace ValidatorBridge.Logic.Models
{
    public static class TransactionSampleData
    {
        public static readonly IEnumerable<TransactionData> sampleTransactionData = new List<TransactionData>
        {
            new TransactionData
            {
                Amount = 55,
                FromAddress = "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
                Nonce = 131,
                Token = "0x2C3fc29c1B9A70e09cD496D8770a66054f72e8B8"
            },
            new TransactionData
            {
                Amount = 20,
                FromAddress = "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
                Nonce = 120,
                Token = "0x722dd3F80BAC40c951b51BdD28Dd19d435762180"
            },
            new TransactionData
            {
                Amount = 200,
                FromAddress = "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
                Nonce = 121,
                Token = "0x722dd3F80BAC40c951b51BdD28Dd19d435762180"
            },
            new TransactionData
            {
                Amount = 1000,
                FromAddress = "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
                Nonce = 102,
                Token = "0x722dd3F80BAC40c951b51BdD28Dd19d435762180"
            }
        };
    }
}
