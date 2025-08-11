// Global değişkenler
let currentSessionToken = null;
let currentUser = null;

// Backend URL - Vercel'den alacağınız URL'i buraya yazın
const API_BASE_URL = 'https://kart-sorgu-xxxx.vercel.app'; // Bu URL'i Vercel'den aldıktan sonra güncelleyin

// Sayfa yüklendiğinde otomatik giriş kontrolü
document.addEventListener('DOMContentLoaded', function() {
    checkAutoLogin();
});

// DOM elementlerini seç
const cardInput = document.getElementById('cardInput');
const processBtn = document.getElementById('processBtn');
const loadingSpinner = document.getElementById('loadingSpinner');
const outputArea = document.getElementById('outputArea');
const outputContent = document.getElementById('outputContent');
const errorMessage = document.getElementById('errorMessage');
const errorText = document.getElementById('errorText');

// Giriş formu elementleri
const loginForm = document.getElementById('loginForm');
const emailInput = document.getElementById('email');
const passwordInput = document.getElementById('password');
const loginBtn = document.getElementById('loginBtn');
const loginLoading = document.getElementById('loginLoading');
const loginError = document.getElementById('loginError');
const loginErrorText = document.getElementById('loginErrorText');
const logoutBtn = document.getElementById('logoutBtn');

// Giriş formu olayları
loginForm.addEventListener('submit', handleLogin);
logoutBtn.addEventListener('click', handleLogout);

// Ana uygulama olayları
processBtn.addEventListener('click', handleProcess);

// Enter tuşu ile de işlem yapabilme
cardInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
        handleProcess();
    }
});

// Ana işlem fonksiyonu
async function handleProcess() {
    const inputValue = cardInput.value.trim();
    
    // Input kontrolü
    if (!inputValue) {
        showError('Lütfen bir değer girin');
        return;
    }
    
    // Session kontrolü
    if (!currentSessionToken) {
        showError('Oturum geçersiz. Lütfen tekrar giriş yapın.');
        showLoginForm();
        return;
    }
    
    // UI durumunu güncelle
    setLoading(true);
    hideError();
    hideOutput();
    
    try {
        // Backend'e istek gönder
        const response = await fetch(`${API_BASE_URL}/api/process`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-Session-Token': currentSessionToken
            },
            body: JSON.stringify({ inputValue })
        });
        
        const data = await response.json();
        
        if (response.ok && data.success) {
            // Başarılı sonuç
            showOutput(data.result, data.originalInput);
        } else {
            // Hata durumu
            if (response.status === 401) {
                showError('Oturum geçersiz. Lütfen tekrar giriş yapın.');
                showLoginForm();
            } else {
                showError(data.error || 'Bir hata oluştu');
            }
        }
        
    } catch (error) {
        console.error('Hata:', error);
        showError('Sunucu bağlantısında hata oluştu');
    } finally {
        setLoading(false);
    }
}

// Loading durumunu ayarla
function setLoading(isLoading) {
    if (isLoading) {
        loadingSpinner.classList.remove('hidden');
        processBtn.disabled = true;
        processBtn.classList.add('opacity-50', 'cursor-not-allowed');
    } else {
        loadingSpinner.classList.add('hidden');
        processBtn.disabled = false;
        processBtn.classList.remove('opacity-50', 'cursor-not-allowed');
    }
}

// Output alanını göster
function showOutput(result, originalInput) {
    outputContent.innerHTML = `
        <div class="space-y-3">
            <div class="flex items-start">
                <i class="fas fa-check-circle text-green-500 mt-1 mr-3"></i>
                <div class="flex-1">
                    <p class="text-gray-800 font-medium">${result}</p>
                </div>
            </div>
            <div class="border-t pt-3">
                <p class="text-sm text-gray-600">
                    <strong>Orijinal Giriş:</strong> ${originalInput}
                </p>
            </div>
        </div>
    `;
    outputArea.classList.remove('hidden');
    
    // Smooth scroll to output
    outputArea.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

// Output alanını gizle
function hideOutput() {
    outputArea.classList.add('hidden');
}

// Hata mesajını göster
function showError(message) {
    errorText.textContent = message;
    errorMessage.classList.remove('hidden');
    
    // Smooth scroll to error
    errorMessage.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

// Hata mesajını gizle
function hideError() {
    errorMessage.classList.add('hidden');
}

// Otomatik giriş kontrolü
async function checkAutoLogin() {
    const savedEmail = localStorage.getItem('userEmail');
    const savedPassword = localStorage.getItem('userPassword');
    
    if (savedEmail && savedPassword) {
        // Otomatik giriş yap
        await performLogin(savedEmail, savedPassword, true);
    }
}

// Giriş işlemi
async function handleLogin(e) {
    e.preventDefault();
    
    const email = emailInput.value.trim();
    const password = passwordInput.value;
    
    if (!email || !password) {
        showLoginError('Lütfen tüm alanları doldurun');
        return;
    }
    
    // Giriş bilgilerini localStorage'a kaydet
    localStorage.setItem('userEmail', email);
    localStorage.setItem('userPassword', password);
    
    await performLogin(email, password, false);
}

// Giriş işlemini gerçekleştir
async function performLogin(email, password, isAutoLogin = false) {
    if (!isAutoLogin) {
        setLoginLoading(true);
        hideLoginError();
    }
    
    try {
        const response = await fetch(`${API_BASE_URL}/api/login`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ email, password })
        });
        
        const data = await response.json();
        
        if (response.ok && data.success) {
            // Başarılı giriş
            currentSessionToken = data.sessionToken;
            currentUser = data.user;
            showMainApp();
        } else {
            // Hata durumu
            if (!isAutoLogin) {
                showLoginError(data.error || 'Giriş yapılamadı');
            } else {
                // Otomatik giriş başarısızsa localStorage'ı temizle
                localStorage.removeItem('userEmail');
                localStorage.removeItem('userPassword');
            }
        }
        
    } catch (error) {
        console.error('Giriş hatası:', error);
        if (!isAutoLogin) {
            showLoginError('Sunucu bağlantısında hata oluştu');
        } else {
            // Otomatik giriş başarısızsa localStorage'ı temizle
            localStorage.removeItem('userEmail');
            localStorage.removeItem('userPassword');
        }
    } finally {
        if (!isAutoLogin) {
            setLoginLoading(false);
        }
    }
}

// Çıkış işlemi
async function handleLogout() {
    try {
        if (currentSessionToken) {
            await fetch(`${API_BASE_URL}/api/logout`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ sessionToken: currentSessionToken })
            });
        }
        
        // Local state'i temizle
        currentSessionToken = null;
        currentUser = null;
        
        // localStorage'dan giriş bilgilerini de temizle
        localStorage.removeItem('userEmail');
        localStorage.removeItem('userPassword');
        
        showLoginForm();
        
    } catch (error) {
        console.error('Çıkış hatası:', error);
        // Hata olsa bile local state'i temizle
        currentSessionToken = null;
        currentUser = null;
        
        // localStorage'dan giriş bilgilerini de temizle
        localStorage.removeItem('userEmail');
        localStorage.removeItem('userPassword');
        
        showLoginForm();
    }
}

// Giriş loading durumunu ayarla
function setLoginLoading(isLoading) {
    if (isLoading) {
        loginLoading.classList.remove('hidden');
        loginBtn.disabled = true;
        loginBtn.classList.add('opacity-50', 'cursor-not-allowed');
    } else {
        loginLoading.classList.add('hidden');
        loginBtn.disabled = false;
        loginBtn.classList.remove('opacity-50', 'cursor-not-allowed');
    }
}

// Giriş hata mesajını göster
function showLoginError(message) {
    loginErrorText.textContent = message;
    loginError.classList.remove('hidden');
}

// Giriş hata mesajını gizle
function hideLoginError() {
    loginError.classList.add('hidden');
}

// Ana uygulamayı göster
function showMainApp() {
    document.getElementById('loginContainer').style.display = 'none';
    document.getElementById('mainApp').style.display = 'block';
    // Input alanına focus ol
    setTimeout(() => {
        if (cardInput) {
            cardInput.focus();
        }
    }, 100);
}

// Giriş formunu göster
function showLoginForm() {
    document.getElementById('loginContainer').style.display = 'block';
    document.getElementById('mainApp').style.display = 'none';
    // Form alanlarını temizle
    if (emailInput) emailInput.value = '';
    if (passwordInput) passwordInput.value = '';
    hideLoginError();
}
