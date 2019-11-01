########### Python 3.2 #############
import http.client, urllib.request, urllib.parse, urllib.error, base64, os, json


headers = {
    # Request headers
    'Ocp-Apim-Subscription-Key': '652c962bc61d46e3aba7cd849aca2e6c',
}

params = urllib.parse.urlencode({
    # Request parameters
    #'$filter': "TimeStamp gt 2019-08-10T00:00:00Z"
    #'$top': '1'
    #'$skip': '{string}',
    #'$orderby': '{string}',
    #'$select': '{string}',
    '_lid':"mxintadm",
    '_lpwd':"giEQ8i5tPxYiuY?",
    'oslc.where':''
})

try:
    conn = http.client.HTTPSConnection("bacproxy.bacl.net",8080)
    
    conn.set_tunnel('api-test.bne.com.au')

    conn.request("GET", "/mxsr/mxsr?%s" % params, "{body}", headers)
    response = conn.getresponse()
    data = json.load(response)
    print(data)
    conn.close()

except Exception as e:
    print("[Errno {0}] {1}".format(e.errno, e.strerror))

####################################