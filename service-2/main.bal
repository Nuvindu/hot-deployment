import ballerina/http;

configurable int port = 8081;

service / on new http:Listener(port) {
    resource function get .() returns json {
        return {"message": "Request received", "port": port};
    }
    
    resource function get health() returns json {
        return {"status": "running", "port": port};
    }
}
