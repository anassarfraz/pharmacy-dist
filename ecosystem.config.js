module.exports = {
  apps: [
    {
      name: 'pharmacare-pos',
      script: 'server.js',
      cwd: __dirname,
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 3000,
        HOSTNAME: '0.0.0.0',
        MONGODB_URI: 'mongodb://127.0.0.1:27017/pharmacy',
      },
    },
  ],
};
