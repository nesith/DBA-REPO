import requests, urllib

headers = {
    # Request headers
    'Ocp-Apim-Subscription-Key': '652c962bc61d46e3aba7cd849aca2e6c'
}

params = urllib.parse.urlencode({
    # Request parameters
    '$filter': 'TimeStamp gt 2018-07-24T00:00:00Z'
    #'$top': '1'
    #'$skip': '{string}',
    #'$orderby': '{string}',
    #'$select': '{string}',
})

response = requests.get('https://api-test.bne.com.au:443/mxsr/mxsr?',headers=headers)

print(response.content)