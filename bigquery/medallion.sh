export REGION="europe-west1"
export PROJECT_ID="syntio-onboarding-prod"
export BRONZE="mk_bronze"
export SILVER="mk_silver"
export GOLD="mk_gold"

bq mk --location=$REGION --dataset $PROJECT_ID:$BRONZE
bq mk --location=$REGION --dataset $PROJECT_ID:$SILVER
bq mk --location=$REGION --dataset $PROJECT_ID:$GOLD
