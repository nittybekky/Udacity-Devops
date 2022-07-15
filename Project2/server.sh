# This script automates the entire process of creating a new stack or updating an existing stack.

# First, we want to make sure you are working with the correct profile to avoid environment mix-up
echo "**************************************** SECURITY CHECK!!!*********************************************"
echo "Please Confirm You Are Running Script on Test Environment"
echo "CURRENT_AWS_PROFILE =" $AWS_PROFILE
echo "Note: If the AWS_PROFILE value is blank, you are using your default profile."
echo " "
read -p "Press Enter If You're All Clear IF NOT, Press Ctrl+C and use the right Profile..."
echo "All Clear!! You may proceed..."
echo "  "
echo "  "

# This section checks for the existence of the stack to decide if a new stack will be created or the stack exists and needs to be updated
echo "**************************************** CLOUDFORMATION *********************************************"
read -p 'Please Enter the correct StackName: ' stack_name
# stack_name=$1
#$STACK_NAME
region="us-east-1"
#$REGION Limiting user to us-east-1 region
environment_name="EnvironmentName"
# EnvironmentName IS THE IMPORTANT PARAMETER THAT CUTS ACROSS ENTIRE STACK

# Line 24 describes the particular stack with all its long details
# aws cloudformation describe-stacks --no-paginate --region $region --stack-name $stack_name
# Line 28 finds that the stack exists but instead of listing all the available stack details, will store the output of the query parameter provided --in this case, the EnvironmentName Param value to the 'check' variable
echo "Validating StackName..."
echo " "
check=$(aws cloudformation describe-stacks --region $region --query "Stacks[?StackName=='$stack_name'][].Parameters[?ParameterKey=='$environment_name'].ParameterValue" --output text)
echo $check
if ! [ "$check" ]
then
    echo "Stack Does not exist. Should Call create.sh"
    read -p "Press Enter to Create Stack..."
    echo "Stack creation in progress..."
    aws cloudformation create-stack --stack-name $stack_name --template-body file://ourservers.yml  --parameters ParameterKey=HostIP,ParameterValue=$(curl -s https://checkip.amazonaws.com/) --capabilities "CAPABILITY_IAM" "CAPABILITY_NAMED_IAM" --region=us-east-1
else
    echo "STACK ENVIRONMENT NAME: " $check
    echo "Stack Exists."
    read -p 'Please Press 1 to UPDATE or 2 to DELETE stack: ' stack_option
    update=1
    delete=2
    if [ "$stack_option" == "$update" ]
    then
        read -p "Press Enter to UPDATE Stack..."
        echo " "
        echo "Stack update in progress..."
        aws cloudformation update-stack --stack-name $stack_name --template-body file://ourservers.yml  --parameters ParameterKey=HostIP,ParameterValue=$(curl -s https://checkip.amazonaws.com/) --capabilities "CAPABILITY_IAM" "CAPABILITY_NAMED_IAM" --region=us-east-1
    elif [ "$stack_option" == "$delete" ]
    then
        read -p "Press Enter to DELETE Stack..."
        echo " "
        echo "Stack delete in progress..."
        aws cloudformation delete-stack --stack-name $stack_name --region $region

    else
        echo "Wrong Option. Try Again."
        echo "Exiting..."
    fi
fi