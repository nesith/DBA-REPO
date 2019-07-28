import requests, urllib

headers = {
    # Request headers
    'Ocp-Apim-Subscription-Key': '967a5343501f490bbe941e0ec780e67e'
}

params = urllib.parse.urlencode({
    # Request parameters
    '$filter': 'TimeStamp gt 2018-07-24T00:00:00Z'
    #'$top': '1'
    #'$skip': '{string}',
    #'$orderby': '{string}',
    #'$select': '{string}',
})

response = requests.get('https://api-test.bne.com.au/api/v2/flights?',headers=headers)

print(response.content)