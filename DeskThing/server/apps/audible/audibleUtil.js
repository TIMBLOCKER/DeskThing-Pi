import child_process from 'child_process';
import axios from 'axios';

const PORT = process.env.AUDIBLE_PORT || 5000;
const BASE_URL = `http://localhost:${PORT}`;

// Spawn the Python process
const pythonProcess = child_process.spawn('python', ['./apps/audible/audibleUtils.py']);

pythonProcess.stdout.on('data', async (data) => {
    console.log(data.toString());
    try {
        const jsonData = JSON.parse(data.toString().trim());
        switch (jsonData.type) {
          case 'captcha':
            console.log("Handling captcha")
            handleCaptcha(jsonData.url);
            break;
            case 'otp':
            console.log("Handling otp")
            handleOTP();
            break;
            case 'cvf':
            console.log("Handling cvf")
            handleCVF();
            break;
            case 'approval':
            console.log("Handling approval")
            handleApproval();
            break;
            case 'message':
            console.log("Received Message: ", jsonData.message)
            break;
          default:
            console.log('Unknown message type:', jsonData.type);
        }
      } catch (error) {
        console.error('Error parsing or processing message from Python:', error.message);
      }
  });
  
  // Handle errors from the Python process
  pythonProcess.stderr.on('data', (data) => {
    console.error(`Error from Python: ${data}`);
  });

pythonProcess.on('close', (code) => {
    console.log(`Python process exited with code ${code}`);
  });

  function handleCaptcha(captchaUrl) {
    console.log(`Captcha required! Please solve it at ${captchaUrl}:`);
    process.stdin.once('data', (data) => {
      sendDataToPython({ answer: data.toString().trim() });
    });
  }
  
  function handleOTP() {
    console.log('OTP required! Please enter OTP:');
    process.stdin.once('data', (data) => {
      sendDataToPython({ answer: data.toString().trim() });
    })
  }
  
  function handleCVF() {
    console.log('CVF required! Please enter CVF:');
    process.stdin.once('data', (data) => {
      sendDataToPython({ answer: data.toString().trim() });
    });
  }
  
  function handleApproval() {
    console.log('Approval alert detected! Please press enter after you approve the notification:');
    process.stdin.once('data', (data) => {
      sendDataToPython({ answer: data.toString().trim() });
    });
  }
  
  function sendDataToPython(data) {
    pythonProcess.stdin.write(JSON.stringify(data) + '\n');
  }

export async function authenticate(email, password, countryCode) {
    try {
        console.log("Attempting to authenticate");
      const response = await axios.post(`${BASE_URL}/auth`, {
        email,
        password,
        countryCode,
      });
      if (response.data.success) {
        return response.data.auth;
      } else {
        console.error('Auth Error Response: ', response);
        throw new Error('Authentication failed:', response);
      }
    } catch (error) {
      console.error('Error during authentication:', error);
    }
  }

export async function get(url, params) {
  try {
    console.log("Attempting to get data");
    const response = await axios.get(`${BASE_URL}/get`, {
      params: {
        url: url,
        params: JSON.stringify(params) 
      },
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    if (response.data.success) {
      return response.data;
    } else {
      throw new Error(`Get Data Response: `, response.data);
    }
  } catch (error) {
    console.error(`Get Data Failed: `, error);
    throw new Error(`Get Data Failed: `, error);
  }
}
export async function post(url, params) {
  try {
    console.log("Attempting to post data");
    //const response = await axios.post(`${BASE_URL}/post`, { url, params });
    const response = await axios.get(`${BASE_URL}/post`, {
      params: {
        url: url,
        params: JSON.stringify(params) 
      },
      headers: {
        'Content-Type': 'application/json'
      }
    });
    if (response.data.success) {
      return response.data;
    } else {
      throw new Error(`Post Data Response: `, response.data);
    }
  } catch (error) {
    console.error(`Post Data Failed: `, error.response);
    throw new Error(`Post Data Failed: `, error.response);
  }
}
export async function put(url, params) {
  try {
    console.log("Attempting to put data");
    const response = await axios.get(`${BASE_URL}/put`, {
      params: {
        url: url,
        params: JSON.stringify(params) 
      },
      headers: {
        'Content-Type': 'application/json'
      }
    });
    if (response.data.success) {
      return response.data;
    } else {
      throw new Error(`Put Data Response: `, response.data);
    }
  } catch (error) {
    console.error(`Put Data Failed: `, error);
    throw new Error(`Put Data Failed: `, error.response);
  }
}

export async function getLibrary() {
  try {
    console.log("Attempting to get library");
    const books = await get('/1.0/library', {'response_groups': 'listening_status, media'});
    
    const simplifiedBooks = await books.data.items.map(book => {
      // Find the first available image URL
      const firstImageUrl = Object.values(book.product_images || {})[0];
      return {
        image_url: firstImageUrl,
        title: book.title,
        progress_percent: book.listening_status ? book.listening_status.percent_complete : null,
        total_length_min: book.runtime_length_min,
        length_left_sec: book.listening_status ? book.listening_status.time_remaining_seconds : null,
        asin: book.asin
      };
    });
    console.log(JSON.stringify(simplifiedBooks));
    return simplifiedBooks;
  } catch (e) {
    console.error(e);
  }
}
