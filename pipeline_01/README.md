steps:

create buckets in S3:
crete raw, processed and final buckets.

create IAM roles:
- One Role (using Lambda service) should have permissions over S3 and Glue.
- Second Role (usign Glue service) should have permissions over S3 and Glue.
