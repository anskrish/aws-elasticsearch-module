# Run Elasticsearch Curator from AWS Lambda.
#
# Edit curator.yaml to define which indices should be purged.

import os
import curator
import yaml
from curator.exceptions import NoIndices
from elasticsearch import Elasticsearch, RequestsHttpConnection
from requests_aws4auth import AWS4Auth

# This is the entry point where Lambda will start execution.
def handler(event, context):     
    cluster_name = os.environ["NAME"]
    region = os.environ["REGION"]
    endpoint = os.environ["ENDPOINT"]
    prefix = os.environ["PREFIX"]
    days = int(os.environ["DAYS"])
    # For this function, we don't care about 'event' and 'context',
    # but they need to be in the function signature anyway.


    # Create a place to track any indices that are deleted.
    deleted_indices = {}

    # Create a place to track backup indices
    backup_indices = {}

    # We can define multiple Elasticsearch clusters to manage, so we'll have
    # an outer loop for working through them.

    deleted_indices[cluster_name] = []
    backup_indices[cluster_name] = []

    awsauth = AWS4Auth(os.getenv('AWS_ACCESS_KEY_ID'),
                       os.getenv('AWS_SECRET_ACCESS_KEY'),
                       region, 'es',
                       session_token=os.getenv('AWS_SESSION_TOKEN'))

    # Create a collection to the cluster. We're using mangaged clusters in
    # AWS, so we can enable SSL security.
    es = Elasticsearch(endpoint, use_ssl=True,
                       verify_certs=True, http_auth=awsauth,
                       connection_class=RequestsHttpConnection)

        # Iterate through the patterns defined in our config for the cluster.
        
    
    print('Checking "%s" indices on %s cluster.' %
          (prefix, cluster_name))

    # Fetch all the index names.
    index_list = curator.IndexList(es)

    # Reduce the list to those that match the prefix.
    index_list.filter_by_regex(kind='prefix', value=prefix)
    # Reduce again, by age.
    index_list.filter_by_age(source='name', direction='older',
                             timestring='%Y.%m.%d', unit='days',
                             unit_count=days)
    print("Indices: {}".format(index_list.indices))
    try:
        curator.DeleteIndices(index_list).do_action()
        deleted_indices[cluster_name].extend(index_list.indices)

    except NoIndices:
        pass

    lambda_response = {'backup': backup_indices, 'deleted': deleted_indices}
    print(lambda_response)
    return lambda_response


if __name__ == "__main__":
    handler('', '')

