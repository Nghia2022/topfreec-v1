public class FCWebCallout implements HttpCalloutMock {

    public static HttpRequest request;
    public static HttpResponse response;

    public HTTPResponse respond(HTTPRequest req) {
        request = req;
        response = new HttpResponse();
        response.setStatusCode(200);
        return response;
    }

    @future(callout=true)
    public static void callout(String url, String body) {

        if (Test.isRunningTest()) {
            Test.setMock(HttpCalloutMock.class, new FCWebCallout());
        }

        Http h = new Http();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(body);

        h.send(req);
    }
}
