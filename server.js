const grpc = require('@grpc/grpc-js');
const protoLoader = require('@grpc/proto-loader');
const packageDef = protoLoader.loadSync('todo.proto', {});
const grpcObject = grpc.loadPackageDefinition(packageDef); // loads the grpc package
const todoPackage = grpcObject.todoPackage;

const server = new grpc.Server();
server.bindAsync("0.0.0.0:40000",
     grpc.ServerCredentials.createInsecure(),
     (err, port) => {
        if (err) {
          console.error('bindAsync error:', err);
          return;
        }
        console.log(`gRPC server listening on ${port}`);
        server.start();
      }
    );
server.addService(todoPackage.Todo.service, // map the methods for the proto service 
    {
        "createTodo" : createTodo,
        "readTodos" : readTodos
    });

const todos = []
function createTodo (call, callback) {
    const todoItem = {
        "id": todos.length + 1,
        "text": call.request.text
    }
    todos.push(todoItem)
    callback(null, todoItem) // specify payload(auto calculated) and send back todo item 
}

function readTodos (call, callback) {

}
