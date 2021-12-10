
import boto3
import pprint
pp = pprint.PrettyPrinter(indent=4)

iam = boto3.client('iam')

def lambda_handler(event, context):

    unapproved_userlist = []
SENDER = "<david.rivera@ucop.edu>" # MUST be registered in SES - this script does not use the global SES setup. please refer to other script for global SES usage.
RECIPIENT = "david.rivera@ucop.edu"
AWS_REGION = "us-west-2"   #change if sending from another region
CHARSET = "UTF-8"
SUBJECT = "Generic Lambda Email Response from a python script - for testing purposes only"
 # for non-HTML emails
BODY_TEXT = ("Amazon SES Test (Python)\r\n"
             "Email sent using "
             "AWS SDK for Python (Boto)."
             )
BODY_HTML = """
    <html>
    <head></head>
    <body>
      <p> To be used when sending ses emails in Lambda scripts being developed 
      <p> The python runtime script is just a template, one must just plug their boto3 code or other python type code in to have it appropriately complete a transaction.
      <ul>
            """
#BODY_HTML +=  values
BODY_HTML +="""</u1>
     </p>
        </body>
        </html>
                    """


client = boto3.client('ses', region_name="us-west-2")


    # Try to send the email.
try:
    response = client.send_email(
      Destination={
          'ToAddresses': [RECIPIENT
         ],
      },
      Message={
          'Body': {
              'Html': {
                  'Charset': CHARSET,
                  'Data': BODY_HTML,


               },
               'Text': {
                   'Charset': CHARSET,
                   'Data': BODY_TEXT,

               },
           },
           'Subject': {
               'Charset': CHARSET,
               'Data': SUBJECT,
           },
      },
      Source=SENDER,
    )
# Display an error if something goes wrong.
except ClientError as e:
    print(e.response['Error']['Message'])
else:
    print("Email sent! Message ID:"),
    print(response['MessageId'])
