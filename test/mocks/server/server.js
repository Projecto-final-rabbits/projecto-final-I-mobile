const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const os = require('os');

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// In-memory database for orders
let orders = [
    {
        id: '1',
        customerName: 'John Doe',
        customerEmail: 'john@example.com',
        customerPhone: '+1234567890',
        status: 'pending',
        total: 125.50,
        items: [
            {
                id: '101',
                name: 'Product 1',
                quantity: 2,
                price: 50.25
            },
            {
                id: '102',
                name: 'Product 2',
                quantity: 1,
                price: 25.00
            }
        ],
        createdAt: new Date().toISOString()
    },
    {
        id: '2',
        customerName: 'Jane Smith',
        customerEmail: 'jane@example.com',
        customerPhone: '+1987654321',
        status: 'completed',
        total: 75.99,
        items: [
            {
                id: '201',
                name: 'Product 3',
                quantity: 3,
                price: 25.33
            }
        ],
        createdAt: new Date().toISOString()
    }
];

// GET all orders
app.get('/orders', (req, res) => {
    res.status(200).json(orders);
});

// GET order by ID
app.get('/orders/:id', (req, res) => {
    const order = orders.find(o => o.id === req.params.id);

    if (order) {
        res.status(200).json(order);
    } else {
        res.status(404).json({ message: 'Order not found' });
    }
});

// POST create new order
app.post('/orders', (req, res) => {
    const newOrder = req.body;

    // Ensure the order has an ID if not provided
    if (!newOrder.id) {
        newOrder.id = (orders.length + 1).toString();
    }

    // Ensure createdAt is set
    if (!newOrder.createdAt) {
        newOrder.createdAt = new Date().toISOString();
    }

    orders.push(newOrder);
    res.status(201).json(newOrder);
});

// Function to get network interfaces
function getNetworkIPs() {
    const interfaces = os.networkInterfaces();
    const addresses = [];

    Object.keys(interfaces).forEach((interfaceName) => {
        interfaces[interfaceName].forEach((iface) => {
            // Skip internal and non-IPv4 addresses
            if (iface.family === 'IPv4' && !iface.internal) {
                addresses.push(iface.address);
            }
        });
    });

    return addresses;
}

// Start server on all network interfaces
app.listen(PORT, '0.0.0.0', () => {
    const networkIPs = getNetworkIPs();

    console.log(`\n🚀 Mock server running on port ${PORT}`);
    console.log('\n📱 Access from your network:');

    if (networkIPs.length > 0) {
        networkIPs.forEach(ip => {
            console.log(`   http://${ip}:${PORT}`);
        });
    } else {
        console.log('   No network interfaces detected');
    }

    console.log('\n📱 Access from your local machine:');
    console.log(`   http://localhost:${PORT}`);
    console.log(`   http://127.0.0.1:${PORT}`);

    console.log('\n📋 Available endpoints:');
    console.log(`   GET    http://[YOUR-IP]:${PORT}/orders`);
    console.log(`   GET    http://[YOUR-IP]:${PORT}/orders/:id`);
    console.log(`   POST   http://[YOUR-IP]:${PORT}/orders`);

    console.log('\n🔍 Example API usage:');
    console.log(`   curl http://localhost:${PORT}/orders`);
    console.log(`   curl http://localhost:${PORT}/orders/1`);
});

module.exports = app; // Export for testing 