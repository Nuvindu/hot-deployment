import ballerina/http;
import ballerina/io;

service / on new http:Listener(8082) {
    resource function get .() returns error? {
        io:println("Received a request in 8082");
    }

    resource function get health() returns http:Response|error {
        http:Response response = new;
        response.statusCode = 200;
        return response;
    }
}
