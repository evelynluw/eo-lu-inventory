echo "Running pipeline.sh"
bash pipeline.sh > output_file.txt
echo "DONE WITH PIPELINE"
aws s3 cp output_file.txt s3://eo-lu-inventory/latest_data/output_file.txt
aws sns publish --topic-arn 'arn:aws:sns:us-east-2:233712923269:ReadyForShutdown' --region 'us-east-2' --message 'SHUTDOWN EC2'

