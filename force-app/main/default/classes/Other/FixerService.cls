public with sharing class FixerService {
    private static FixerCredentials__c getToken() {
        return FixerCredentials__c.getValues('Production');
    }

    private static string makeCallout(string Url) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Url);
        request.setMethod('GET');
        HttpResponse jsonResponse = http.send(request);
        if(jsonResponse.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse.getBody());
            Boolean success = (Boolean) results.get('success');
            if (!success) {
                Map<String, Object> error = (Map<String, Object>) results.get('error');
                string errorInfo = (string) error.get('info');
                string errorType = (string) error.get('type');
                if (errorType == 'base_currency_access_restricted') {
                    throw new AuraHandledException(System.Label.ApiTokenRestriction);
                }
                throw new AuraHandledException(System.Label.ApiWrongResponse + '\n' + errorInfo);
            }
            return jsonResponse.getBody();
        } else {
            throw new AuraHandledException(System.Label.ApiResponseError);
        }
    }

    @AuraEnabled(cacheable=false)
    public static string getRate(string buyCurrency, string sellCurrency) {
        FixerCredentials__c AuthToken = GetToken();
        string url = AuthToken.BaseUrl__c + 'latest';
        url += '?access_key='   + AuthToken.AccessToken__c;
        url += '&base='         + sellCurrency;
        url += '&symbols='      + buyCurrency;

        return MakeCallout(url);
    }
}



