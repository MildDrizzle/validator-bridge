using Microsoft.ML.Data;

namespace ValidatorBridge.Logic.Models
{
    public class TransactionData
    {
        [LoadColumn(0)]
        public string FromAddress { get; set; }

        [LoadColumn(1)]
        public string Token { get; set; }

        [LoadColumn(2)]
        public float Amount { get; set; }

        [LoadColumn(3)]
        public float Nonce { get; set; }

        [LoadColumn(4)]
        public bool Label { get; set; }
    }
}
