########### Python 3.2 #############
import http.client, urllib.request, urllib.parse, urllib.error, base64

headers = {
    # Request headers
    'Ocp-Apim-Subscription-Key': '967a5343501f490bbe941e0ec780e67e',
}

params = urllib.parse.urlencode({
    # Request parameters
    '$filter': 'TimeStamp gt 2018-07-24T00:00:00Z'
    #'$top': '1'
    #'$skip': '{string}',
    #'$orderby': '{string}',
    #'$select': '{string}',
})

try:
    conn = http.client.HTTPSConnection('api-test.bne.com.au')
    conn.request("GET", "/api/v2/flights?%s" % params, "{body}", headers)
    response = conn.getresponse()
    data = response.read()
    print(data)
    conn.close()
except Exception as e:
    print("[Errno {0}] {1}".format(e.errno, e.strerror))

####################################