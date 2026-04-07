const app = {
    state: {
        devices: [],
        currentDevice: null,
        metrics: { scanned: 0, rewards: 0, recycledMaterials: 0, sold: 0, co2Saved: 0 },
        scanner: null
    },

    // Navigation Subsystem
    nav(screenId) {
        document.querySelectorAll('.screen').forEach(el => el.classList.remove('active'));
        document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
        
        document.getElementById(`screen-${screenId}`).classList.add('active');
        if(document.getElementById(`nav-${screenId}`)) {
            document.getElementById(`nav-${screenId}`).classList.add('active');
        }

        // Camera Management
        if(screenId === 'scan') {
            this.startScanner();
        } else {
            this.stopScanner();
        }

        if(screenId === 'dashboard') this.updateDashboard();
        if(screenId === 'profile') this.renderList('Resale');
    },

    startScanner() {
        if (!this.state.scanner) {
            this.state.scanner = new Html5Qrcode("qr-reader");
        }
        
        const config = { fps: 10, qrbox: { width: 250, height: 250 } };
        
        this.state.scanner.start(
            { facingMode: "environment" }, 
            config, 
            (decodedText) => {
                document.getElementById('imei-input').value = decodedText;
                this.analyzeDevice(decodedText);
            },
            (errorMessage) => {
                // Ignore errors for continuous scanning
            }
        ).catch(err => {
            console.error("Camera access error:", err);
            alert("Unable to access camera. Please ensure permissions are granted.");
        });
    },

    stopScanner() {
        if (this.state.scanner && this.state.scanner.isScanning) {
            this.state.scanner.stop().then(() => {
                console.log("Scanner stopped");
            }).catch(err => console.error("Error stopping scanner", err));
        }
    },

    toggleCamera() {
        if (this.state.scanner) {
            this.stopScanner();
            setTimeout(() => this.startScanner(), 500);
        }
    },

    // 2. IMEI Scan / QR Input
    analyzeDevice(scannedValue) {
        const input = scannedValue || document.getElementById('imei-input').value;
        const imei = input || `35${Math.floor(Math.random()*10000000000000).toString().padStart(13, '0')}`;
        
        this.nav('analysis');
        document.getElementById('analysis-loading').classList.remove('hidden');
        document.getElementById('analysis-result').classList.add('hidden');

        // AI Mock Request
        setTimeout(() => this.processAiLogic(imei), 1500);
    },

    processAiLogic(imei) {
        // AI Logic Engine using Encryption Logic Base
        let data = {};
        
        // Try to parse as JSON if it looks like one (from QR)
        try {
            if (imei.startsWith('{')) {
                const parsed = JSON.parse(imei);
                data = {
                    model: parsed.model || "Custom Device",
                    health: parsed.health || "Good",
                    age: parsed.age || 12,
                    tag: parsed.tag || "Repairable",
                    val: parsed.val || 200
                };
            } else {
                const seed = parseInt(imei.slice(-1)) || Math.floor(Math.random() * 10);
                if (seed < 3) {
                    data = { model: "iPhone 14 Pro", health: "Excellent", age: 12, tag: "Rare/High-Value", val: 800 };
                } else if (seed < 7) {
                    data = { model: "Samsung Galaxy S21", health: "Fair", age: 36, tag: "Repairable", val: 150 };
                } else {
                    data = { model: "Standard Android Node", health: "Poor", age: 84, tag: "Non-Repairable", val: 0 };
                }
            }
        } catch (e) {
            data = { model: "Unknown Device", health: "Unknown", age: 0, tag: "Non-Repairable", val: 0 };
        }

        this.state.currentDevice = { imei, ...data, status: 'Analyzed' };
        
        // 1 & 8. User Profile & Metrics Update (Scanned count)
        if(!this.state.devices.find(d => d.imei === imei)) {
            this.state.devices.push(this.state.currentDevice);
            this.state.metrics.scanned += 1;
            this.updateDashboard();
        }

        // Render outputs
        document.getElementById('analysis-loading').classList.add('hidden');
        document.getElementById('analysis-result').classList.remove('hidden');
        
        document.getElementById('res-model').innerText = data.model;
        document.getElementById('res-age').innerText = `${data.age} Months`;
        document.getElementById('res-health').innerText = data.health;
        document.getElementById('res-value').innerText = `$${data.val}`;
        
        const tagEl = document.getElementById('res-tag');
        tagEl.innerText = data.tag;
        tagEl.className = `tag ${data.tag === 'Non-Repairable' ? 'non-repairable' : data.tag === 'Repairable' ? 'repairable' : 'rare'}`;
    },

    // 4. Automatic Routing Logic
    routeDevice() {
        const d = this.state.currentDevice;
        if (d.tag === 'Non-Repairable') {
            document.getElementById('wipe-model').innerText = d.model;
            document.getElementById('wipe-imei').innerText = `IMEI: ${d.imei}`;
            this.resetWipeUI();
            this.nav('wiping');
        } else {
            document.getElementById('resale-model').innerText = d.model;
            document.getElementById('resale-imei').innerText = `IMEI: ${d.imei} | Assessed: $${d.val}`;
            this.resetResaleUI();
            this.nav('resale');
        }
    },

    // Routing Logic: Repairable -> Resale Path
    resetResaleUI() {
        document.getElementById('resale-ztep').checked = false;
        const pBtn = document.getElementById('btn-passport');
        pBtn.innerText = 'Update Digital Blockchain Passport';
        pBtn.disabled = true;
        pBtn.style.color = 'var(--warning)'; pBtn.style.borderColor = 'var(--warning)';
        document.getElementById('btn-list-market').disabled = true;
    },

    checkResale() {
        if(document.getElementById('resale-ztep').checked) {
            document.getElementById('btn-passport').disabled = false;
        }
    },

    updatePassport() {
        const btn = document.getElementById('btn-passport');
        btn.innerText = 'Syncing cryptographic nodes...';
        btn.disabled = true;
        
        setTimeout(() => {
            btn.innerText = 'Passport Secured ✓';
            btn.style.color = 'var(--primary)';
            btn.style.borderColor = 'var(--primary)';
            document.getElementById('btn-list-market').disabled = false;
        }, 1200);
    },

    // 5 & 6 & 7. Resale Tracking & Rewards
    listToMarket() {
        this.updateDeviceArray('Listed via Resale');
        this.grantRewards(150, 0, 5); // Points, materials, co2
        this.state.metrics.sold += 1;
        alert(`Device listed securely! You earned 150 PTS.`);
        this.nav('profile');
    },

    // 3. Step-by-Step Data Wiping
    resetWipeUI() {
        [1,2,3].forEach(i => {
            document.getElementById(`wipe-step-${i}`).className = i===1 ? 'step-row active' : 'step-row';
        });
        document.getElementById('btn-wipe-execute').style.display = 'none';
        document.getElementById('btn-wipe-finish').style.display = 'none';
        document.getElementById('wipe-progress').style.width = '0%';
        document.getElementById('cert-area').classList.add('hidden');
        document.getElementById('btn-recycle').classList.add('hidden');
    },

    progressWipe(step) {
        if(step === 1) { // Verified Phase 1 -> Move to Phase 2 active
            document.getElementById('wipe-step-1').className = 'step-row completed';
            const row2 = document.getElementById('wipe-step-2');
            row2.className = 'step-row active';
            row2.querySelector('button').style.display = 'block';
        } else if (step === 3) { // Sign-off -> Cert Gen
            document.getElementById('wipe-step-3').className = 'step-row completed';
            document.getElementById('btn-wipe-finish').style.display = 'none';
            this.generateBlockchainCert();
        }
    },

    executeWipeAnim() {
        const btn = document.getElementById('btn-wipe-execute');
        btn.disabled = true; btn.innerText = 'Overwriting...';
        const pBar = document.getElementById('wipe-progress');
        
        setTimeout(()=> { pBar.style.width = '40%'; }, 500);
        setTimeout(()=> { pBar.style.width = '80%'; }, 1500);
        setTimeout(()=> { 
            pBar.style.width = '100%'; 
            btn.style.display = 'none';
            document.getElementById('wipe-step-2').className = 'step-row completed';
            const row3 = document.getElementById('wipe-step-3');
            row3.className = 'step-row active';
            row3.querySelector('button').style.display = 'block';
        }, 2500);
    },

    // 10. Security & Privacy - SHA256 Web Crypto Implementation
    async generateBlockchainCert() {
        const payload = `WIPE|${this.state.currentDevice.imei}|${Date.now()}|ADMIN_VERIFIED`;
        const encoder = new TextEncoder();
        const data = encoder.encode(payload);
        const hashBuffer = await crypto.subtle.digest('SHA-256', data);
        const hashArray = Array.from(new Uint8Array(hashBuffer));
        const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
        
        const certStr = `CERT-${hashHex.slice(0, 24).toUpperCase()}`;
        this.state.currentDevice.cert = certStr;

        document.getElementById('cert-hash').innerText = certStr;
        document.getElementById('cert-area').classList.remove('hidden');
        document.getElementById('btn-recycle').classList.remove('hidden');
    },

    sendToRecycling() {
        this.updateDeviceArray('Recycled & Wiped');
        this.grantRewards(50, 250, 15); // Points, 250g materials, 15kg CO2
        alert("Transfer logistics authorized. Earned 50 PTS and recovered 250g of raw materials!");
        this.nav('profile');
    },

    // Central Data Management
    updateDeviceArray(status) {
        const cd = this.state.currentDevice;
        const dbEntry = this.state.devices.find(d => d.imei === cd.imei);
        if(dbEntry) {
            dbEntry.status = status;
            dbEntry.cert = cd.cert;
        }
    },

    grantRewards(pts, materials, co2) {
        this.state.metrics.rewards += pts;
        this.state.metrics.recycledMaterials += materials;
        this.state.metrics.co2Saved += co2;
        this.updateDashboard();
    },

    // 9. Dashboard Layout & Summaries
    updateDashboard() {
        const m = this.state.metrics;
        document.getElementById('dash-scanned').innerText = m.scanned;
        document.getElementById('dash-rewards').innerText = m.rewards;
        document.getElementById('dash-recycled').innerText = m.recycledMaterials;
        document.getElementById('dash-sold').innerText = m.sold;
        
        document.getElementById('co2-amount').innerText = `${m.co2Saved} kg`;
        document.getElementById('co2-bar').style.width = `${Math.min(m.co2Saved * 2, 100)}%`;
        document.getElementById('header-pts').innerText = `${m.rewards} PTS`;
    },

    // Tracking List Logic
    renderList(filterType) {
        // Toggle tabs visually
        const tR = document.getElementById('tab-resale');
        const tC = document.getElementById('tab-recycle');
        if(filterType === 'Resale') {
            tR.className = 'nav-btn active'; tC.className = 'nav-btn'; tC.style.borderColor = 'var(--text-muted)'; tC.style.color = 'var(--text-muted)';
            tR.style.borderColor = 'var(--primary)'; tR.style.color = 'var(--primary)';
        } else {
            tC.className = 'nav-btn active'; tR.className = 'nav-btn'; tR.style.borderColor = 'var(--text-muted)'; tR.style.color = 'var(--text-muted)';
            tC.style.borderColor = 'var(--primary)'; tC.style.color = 'var(--primary)';
        }

        const listDiv = document.getElementById('tracking-list');
        listDiv.innerHTML = '';
        
        const filtered = this.state.devices.filter(d => 
            filterType === 'Resale' ? d.status.includes('Listed') : d.status.includes('Recycled')
        );

        if(filtered.length === 0) {
            listDiv.innerHTML = `<div class="text-center text-muted mt-4">No ${filterType} devices found.</div>`;
            return;
        }

        filtered.forEach(d => {
            const color = filterType === 'Resale' ? 'var(--warning)' : 'var(--danger)';
            listDiv.innerHTML += `
                <div class="list-item" style="border-left-color: ${color}">
                    <div>
                        <h4 style="color: white;">${d.model}</h4>
                        <div class="meta">IMEI: ${d.imei}<br>Val: $${d.val} | Health: ${d.health}</div>
                        ${d.cert ? `<div class="cert-box" style="margin-top: 5px; padding: 4px; font-size: 9px; color: ${color}; border-color: ${color}">${d.cert}</div>` : ''}
                    </div>
                    <div class="tag" style="color:${color}; border-color:${color}">${d.status}</div>
                </div>
            `;
        });
    },

    // 11. Simulation Test
    simulateScanData() {
        const testData = [
            { imei: "100000000000002", mock: 2 }, // Rare
            { imei: "200000000000001", mock: 1 }, // Rare
            { imei: "300000000000005", mock: 5 }, // Repairable
            { imei: "400000000000009", mock: 9 }, // Non-Repairable
            { imei: "500000000000008", mock: 8 }  // Non-Repairable
        ];
        
        testData.forEach(item => {
            if(!this.state.devices.find(d => d.imei === item.imei)) {
                this.analyzeMockAutomatically(item.imei, item.mock);
            }
        });
        
        alert("Simulation Complete! 5 mixed-condition devices automatically analyzed, wiped/blockchain certified, pushed to market, and reward metrics updated!");
        this.nav('dashboard');
    },

    analyzeMockAutomatically(imei, seed) {
        let model, h, a, tag, val;
        if(seed < 3)      { model = "iPhone 14 Pro"; h = "Excellent"; a = 12; tag = "Rare/High-Value"; val = 800; }
        else if(seed < 7) { model = "Samsung Galaxy S21"; h = "Fair"; a = 36; tag = "Repairable"; val = 150; }
        else              { model = "Legacy Android"; h = "Poor"; a = 72; tag = "Non-Repairable"; val = 0; }

        const device = { imei, model, health: h, age: a, tag, val, status: '' };
        this.state.metrics.scanned += 1;
        
        if (tag === 'Non-Repairable') {
            device.status = "Recycled & Wiped";
            device.cert = `CERT-SIMULATION-${Math.random().toString(16).slice(2).toUpperCase()}`;
            this.state.metrics.rewards += 50; this.state.metrics.recycledMaterials += 250; this.state.metrics.co2Saved += 15;
        } else {
            device.status = "Listed via Resale";
            this.state.metrics.sold += 1;
            this.state.metrics.rewards += 150; this.state.metrics.co2Saved += 5;
        }
        this.state.devices.push(device);
    }
};

// Start
app.nav('dashboard');
