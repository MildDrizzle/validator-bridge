using Microsoft.ML;
using ValidatorBridge.Logic.Models;

public class Program
{
    private static string BaseDatasetsRelativePath = @"../../../../Data";
    private static string TrainDataRelativePath = $"{BaseDatasetsRelativePath}/transactions_training.csv";

    private static string TrainDataPath = GetAbsolutePath(TrainDataRelativePath);

    private static string BaseModelsRelativePath = @"../../../../MLModels";
    private static string ModelRelativePath = $"{BaseModelsRelativePath}/TransactionsClassification.zip";

    private static string ModelPath = GetAbsolutePath(ModelRelativePath);

    public static void Main(string[] args)
    {
        var mlContext = new MLContext();
        BuildTrainEvaluateAndSaveModel(mlContext);

        TestPrediction(mlContext);

        Console.WriteLine("=============== End of process, hit any key to finish ===============");
        Console.ReadKey();
    }

    private static void TestPrediction(MLContext mlContext)
    {
        ITransformer trainedModel = mlContext.Model.Load(ModelPath, out var _);

        // Create prediction engine related to the loaded trained model
        var predictionEngine = mlContext.Model.CreatePredictionEngine<TransactionData, TransactionDataPrediction>(trainedModel);

        foreach (var transaction in TransactionSampleData.sampleTransactionData)
        {
            var prediction = predictionEngine.Predict(transaction);

            Console.WriteLine($"=============== Single Prediction  ===============");
            Console.WriteLine($"From Address: {transaction.FromAddress}");
            Console.WriteLine($"Token: {transaction.Token}");
            Console.WriteLine($"Amount: {transaction.Amount}");
            Console.WriteLine($"Nonce: {transaction.Nonce}");
            Console.WriteLine($"Prediction Value: {prediction.Prediction} ");
            Console.WriteLine($"Prediction: {(prediction.Prediction ? "Transaction could be fraudulent" : "Not a fraudulent transaction")} ");
            Console.WriteLine($"==================================================");
            Console.WriteLine("");
            Console.WriteLine("");
        }
    }

    private static void BuildTrainEvaluateAndSaveModel(MLContext mlContext)
    {
        // STEP 1: Common data loading configuration
        var trainingDataView = mlContext.Data.LoadFromTextFile<TransactionData>(TrainDataPath, hasHeader: true, separatorChar: ',');

        // STEP 2: Concatenate the features and set the training algorithm
        var pipeline = mlContext.Transforms.Categorical.OneHotEncoding(outputColumnName: "FromAddressEncoded", "FromAddress")
            .Append(mlContext.Transforms.Categorical.OneHotEncoding(outputColumnName: "TokenEncoded", "Token"))
            .Append(mlContext.Transforms.Concatenate("Features", "FromAddressEncoded", "TokenEncoded", "Amount", "Nonce"))
            .Append(mlContext.BinaryClassification.Trainers.FastTree(labelColumnName: "Label", featureColumnName: "Features"));

        Console.WriteLine("=============== Training the model ===============");
        ITransformer trainedModel = pipeline.Fit(trainingDataView);
        Console.WriteLine("");
        Console.WriteLine("");
        Console.WriteLine("=============== Finish the train model. Push Enter ===============");
        Console.WriteLine("");
        Console.WriteLine("");

        // TODO: Evaluate accuracy of model here.

        Console.WriteLine("=============== Saving the model to a file ===============");
        mlContext.Model.Save(trainedModel, trainingDataView.Schema, ModelPath);
        Console.WriteLine("");
        Console.WriteLine("");
        Console.WriteLine("=============== Model Saved =============\n");
    }

    public static string GetAbsolutePath(string relativePath)
    {
        var dataRoot = new FileInfo(typeof(Program).Assembly.Location);
        string assemblyFolderPath = dataRoot.Directory.FullName;

        string fullPath = Path.Combine(assemblyFolderPath, relativePath);

        return fullPath;
    }
}