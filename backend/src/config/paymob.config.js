require('dotenv').config();

const isLive = (process.env.PAYMOB_ENV || 'test').toLowerCase() === 'live';

const paymobConfig = {
  // Environment: 'test' or 'live'
  env: isLive ? 'live' : 'test',
  isLive: isLive,

  // Base Paymob URLs
  baseUrl: 'https://accept.paymob.com',
  intentionUrl: 'https://accept.paymob.com/v1/intention/',

  // API Credentials
  apiKey: process.env.PAYMOB_API_KEY || '',
  secretKey: process.env.PAYMOB_SECRET_KEY || (process.env.PAYMOB_SECRET_KEY_B64 ? Buffer.from(process.env.PAYMOB_SECRET_KEY_B64, 'base64').toString('utf8') : ''),
  publicKey: process.env.PAYMOB_PUBLIC_KEY || '',
  hmacKey: process.env.PAYMOB_HMAC_KEY || '',

  // Integration IDs
  cardIntegrationId: process.env.PAYMOB_CARD_INTEGRATION_ID || '',
  walletIntegrationId: process.env.PAYMOB_WALLET_INTEGRATION_ID || '',
  iframeId: process.env.PAYMOB_IFRAME_ID || '',

  // Currency
  currency: 'EGP',

  // Official Test Credentials from Paymob Documentation & PDF
  testCard: {
    number: '4111111111111111',
    holderName: 'Test Account',
    expiryMonth: '01',
    expiryYear: '39',
    cvv: '123'
  },
  testWallet: {
    number: '01010101010',
    mpin: '123456',
    otp: '123456'
  }
};

module.exports = paymobConfig;
