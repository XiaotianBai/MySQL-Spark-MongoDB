
import org.apache.log4j.LogManager;
import org.apache.spark.mllib.classification.LogisticRegressionModel;
import org.apache.spark.ml.classification.LogisticRegression;
import org.apache.spark.mllib.classification.LogisticRegressionWithLBFGS;
import org.apache.spark.mllib.evaluation.BinaryClassificationMetrics;
import org.apache.spark.mllib.linalg.DenseVector;
import org.apache.spark.sql.Column;
import scala.Tuple2;
import org.apache.spark.mllib.regression.LabeledPoint;
import org.apache.spark.SparkConf;
import org.apache.spark.SparkContext;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.function.Function;
import org.apache.spark.mllib.linalg.Vectors;
import org.apache.spark.mllib.evaluation.MulticlassMetrics;
import org.apache.spark.rdd.RDD;
import static org.apache.spark.sql.functions.*;

import java.util.ArrayList;

public class CV10Fold {
    public static final String COMMA_DELIMITER = ",(?=([^\"]*\"[^\"]*\")*[^\"]*$)";
    public static void main(String[] args) {
        LogManager.getLogger("org").setLevel(org.apache.log4j.Level.OFF);
        SparkConf conf = new SparkConf().setAppName("CV10Fold").setMaster("local[1]");

        double AUC = 0;
        double accuracy = 0;
        double prec = 0;
        double tpr = 0;
        double tnr = 0;
        double fpr = 0;
        double fnr = 0;
        double tpc = 0;
        double tnc = 0;
        double fpc = 0;
        double fnc = 0;

        SparkContext jsc = new SparkContext(conf);
        int minPartition = 1;
        RDD<String> input = jsc.textFile("/home/data/titanic-train.csv", minPartition);
        //RDD<String> input = jsc.textFile("titanic-train.csv", minPartition);

        JavaRDD<String> data = input.toJavaRDD();

        JavaRDD<String>[] tmp = data.randomSplit(new double[]{0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1}, 17);
        ArrayList<JavaRDD<String>> testFolds = new ArrayList<>();
        ArrayList<JavaRDD<String>> trainingFolds = new ArrayList<>();
        for (int i = 0; i < 10; i++) {
            int j = 0;
            testFolds.add(tmp[i]);
            while(j == i) {
                j++;
            }
            trainingFolds.add(tmp[j]);
            for(int k = j + 1; k < 10; k++) {
                if(k != i) trainingFolds.get(i).union(tmp[k]);
            }
        }
        for (int i = 0; i < 10; i++) {
            JavaRDD<String> trainData = trainingFolds.get(i);
            JavaRDD<String> testData = testFolds.get(i);
            JavaRDD<LabeledPoint> training = trainData.filter(l -> !"PassengerId".equals(l.split(COMMA_DELIMITER)[0])).map(line -> {
                String[] params = line.split(COMMA_DELIMITER);
                double label = Double.valueOf(params[1]);
                double gender = params[4].equals("male")? 0: 1;
                double age = params[5].equals("")? 0: Double.valueOf(params[5]);
                double pclass = Double.valueOf(params[2]);
                return new LabeledPoint(label, Vectors.dense(pclass, gender, age));
            });

            JavaRDD<LabeledPoint> test = testData.filter(l -> !"PassengerId".equals(l.split(COMMA_DELIMITER)[0])).map(line -> {
                String[] params = line.split(COMMA_DELIMITER);
                double label = Double.valueOf(params[1]);
                double gender = params[4].equals("male")? 0: 1;
                double age = params[5].equals("")? 0: Double.valueOf(params[5]);
                double pclass = Double.valueOf(params[2]);
                return new LabeledPoint(label, Vectors.dense(pclass, gender, age));
            });


            // Run training algorithm to build the model.
            LogisticRegressionModel model = new LogisticRegressionWithLBFGS()
                    .run(training.rdd());

            // Clear the prediction threshold so the model will return probabilities
            model.clearThreshold();

            // Compute raw scores on the test set.
            JavaRDD<Tuple2<Object, Object>> predictionAndLabels = test.map(
                    new Function<LabeledPoint, Tuple2<Object, Object>>() {
                        public Tuple2<Object, Object> call(LabeledPoint p) {
                            Double prediction = (double)Math.round(model.predict(p.features()));
                            return new Tuple2<Object, Object>(prediction, p.label());
                        }
                    }
            );

            // Get evaluation metrics.
            BinaryClassificationMetrics metrics =
                    new BinaryClassificationMetrics(predictionAndLabels.rdd());

            // Get evaluation metrics.
            MulticlassMetrics metrics2 = new MulticlassMetrics(predictionAndLabels.rdd());

            long tp = predictionAndLabels.filter(pl -> (pl._1()).equals(pl._2()) && pl._1().equals(1d)).count();
            long tn = predictionAndLabels.filter(pl -> (pl._1()).equals(pl._2()) && pl._1().equals(0d)).count();
            long fp = predictionAndLabels.filter(pl -> !(pl._1()).equals(pl._2()) && pl._2().equals(0d)).count();
            long fn = predictionAndLabels.filter(pl -> !(pl._1()).equals(pl._2()) && pl._2().equals(1d)).count();
            AUC += metrics.areaUnderROC();
            tpc += tp;
            tnc += tn;
            fpc += fp;
            fnc += fn;
        }
        accuracy =  ((tpc+tnc)/(tpc+tnc+fpc+fnc));
        prec = (tpc /(tpc + fpc));
        tpr = (tpc / (tpc + fnc));
        fnr = (fnc / (tpc + fnc));
        fpr = (fpc / (tnc + fpc));
        tnr = (tnc / (tnc + fpc));

        System.out.println("********** 10-fold CV **********");
        System.out.println("Precision=  " + prec);
        System.out.println("Accuracy=  " + accuracy);
        System.out.println("AUC=  " + AUC / 10);
        System.out.println("tpr=  " + tpr);
        System.out.println("fnr=  " + fnr);
        System.out.println("fpr=  " + fpr);
        System.out.println("tnr=  " + tnr);



        jsc.stop();
    }
}
