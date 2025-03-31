# Order Mock Server

This is a simple Express server that mocks the Order API endpoints for testing the Flutter app's `OrderRemoteDataSource` implementation.

## Setup

1. Install Node.js dependencies:
```bash
cd test/mocks/server
npm install
```

2. Start the server:
```bash
npm start
```

The server will run on port 3000 and will be accessible:
- From your local machine: `http://localhost:3000`
- From other devices on your network: `http://YOUR-LOCAL-IP:3000`

When the server starts, it will display all available IP addresses you can use to access it from other devices.

## Network Access

The server is configured to be accessible from other devices on your network. This allows you to:

1. Test your Flutter app on a physical device while connecting to this mock server
2. Have multiple developers accessing the same mock API
3. Test your app across different devices simultaneously

Example configuration for Flutter app on a physical device:
```dart
final dio = Dio(BaseOptions(
  baseUrl: 'http://YOUR-COMPUTER-IP:3000',
  contentType: 'application/json',
));
```

## Available Endpoints

- `GET /orders` - Get all orders
- `GET /orders/:id` - Get order by ID
- `POST /orders` - Create a new order

## Testing with the Flutter App

To configure your Flutter app to use this mock server during testing:

1. Update your Dio client configuration in tests to point to the mock server
2. Example test setup:

```dart
void main() {
  late OrderRemoteDataSourceImpl dataSource;
  late Dio mockDio;

  setUp(() {
    mockDio = Dio(BaseOptions(
      baseUrl: 'http://localhost:3000', // Or use the network IP
      contentType: 'application/json',
    ));
    dataSource = OrderRemoteDataSourceImpl(client: mockDio);
  });

  // Your tests here...
}
```

## Order Structure

The mock server uses the same order structure as the Flutter app:

```json
{
  "id": "string",
  "customerName": "string",
  "customerEmail": "string",
  "customerPhone": "string",
  "status": "string",
  "total": 0.0,
  "items": [
    {
      "id": "string",
      "name": "string",
      "quantity": 0,
      "price": 0.0
    }
  ],
  "createdAt": "2023-01-01T00:00:00.000Z"
}
``` 