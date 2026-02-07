// ============================================================================
// UI Controller - Main Application Logic
// ============================================================================
// Connects the simulator and waveform viewer to the DOM, handles user
// interactions, and manages animations.
// ============================================================================

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
    // ========================================================================
    // Initialize Simulator and Viewer
    // ========================================================================
    const simulator = new VendingMachineSimulator();
    const waveformViewer = new WaveformViewer('waveform-canvas');
    
    // ========================================================================
    // DOM Elements
    // ========================================================================
    const btnCoin5 = document.getElementById('btn-coin-5');
    const btnCoin10 = document.getElementById('btn-coin-10');
    const btnSelect = document.getElementById('btn-select');
    const btnReset = document.getElementById('btn-reset');
    
    const creditDisplay = document.getElementById('credit-value');
    const statusText = document.getElementById('status-text');
    const statusLED = document.getElementById('status-led');
    const cycleCount = document.getElementById('cycle-count');
    const clockState = document.getElementById('clock-state');
    const changeIndicator = document.getElementById('change-indicator');
    const itemDisplay = document.getElementById('item-display');
    const logContent = document.getElementById('log-content');
    
    // FSM state nodes
    const stateNodes = {
        'IDLE': document.getElementById('state-idle'),
        'ACCEPT_COIN': document.getElementById('state-accept'),
        'WAIT_SELECTION': document.getElementById('state-wait'),
        'DISPENSE_ITEM': document.getElementById('state-dispense'),
        'RETURN_CHANGE': document.getElementById('state-change')
    };
    
    // ========================================================================
    // Event Handlers
    // ========================================================================
    
    btnCoin5.addEventListener('click', () => {
        simulator.insertCoin5();
        addLogEntry('₹5 coin inserted');
        animateButton(btnCoin5);
    });
    
    btnCoin10.addEventListener('click', () => {
        simulator.insertCoin10();
        addLogEntry('₹10 coin inserted');
        animateButton(btnCoin10);
    });
    
    btnSelect.addEventListener('click', () => {
        if (simulator.getCredit() >= 15) {
            simulator.selectItem();
            addLogEntry('Item selected');
            animateButton(btnSelect);
        } else {
            addLogEntry('Insufficient credit! Need ₹15', true);
        }
    });
    
    btnReset.addEventListener('click', () => {
        simulator.reset();
        addLogEntry('System reset', true);
        changeIndicator.textContent = '-';
        itemDisplay.style.transform = 'translateY(0)';
        animateButton(btnReset);
    });
    
    // Step mode controls removed per user request
    
    // ========================================================================
    // Simulator Callbacks
    // ========================================================================
    
    simulator.onStateChange = (stateName) => {
        updateStateDisplay(stateName);
        updateFSMDiagram(stateName);
        addLogEntry(`State: ${stateName}`, false, true);
    };
    
    simulator.onCreditChange = (credit) => {
        creditDisplay.textContent = `₹${credit}`;
        updateButtonStates();
    };
    
    simulator.onDispense = () => {
        animateDispense();
        addLogEntry('✓ Item dispensed!', false, true);
    };
    
    simulator.onReturnChange = (change) => {
        const changeAmount = change;
        changeIndicator.textContent = `₹${changeAmount}`;
        addLogEntry(`✓ Change returned: ₹${changeAmount}`, false, true);
        
        // Clear change display after 3 seconds
        setTimeout(() => {
            changeIndicator.textContent = '-';
        }, 3000);
    };
    
    simulator.onClockTick = () => {
        cycleCount.textContent = simulator.cycle;
        clockState.textContent = simulator.clk ? '1' : '0';
        waveformViewer.render(simulator.getSignalHistory());
    };
    
    // ========================================================================
    // UI Update Functions
    // ========================================================================
    
    function updateStateDisplay(stateName) {
        statusText.textContent = stateName.replace('_', ' ');
        
        // Update LED color based on state
        statusLED.classList.remove('active');
        
        if (stateName !== 'IDLE') {
            statusLED.classList.add('active');
        }
    }
    
    function updateFSMDiagram(stateName) {
        // Remove active class from all states
        Object.values(stateNodes).forEach(node => {
            if (node) node.classList.remove('active');
        });
        
        // Add active class to current state
        const currentNode = stateNodes[stateName];
        if (currentNode) {
            currentNode.classList.add('active');
        }
    }
    
    function updateButtonStates() {
        const credit = simulator.getCredit();
        
        // Disable select button if insufficient credit
        if (credit < 15) {
            btnSelect.style.opacity = '0.5';
            btnSelect.style.cursor = 'not-allowed';
        } else {
            btnSelect.style.opacity = '1';
            btnSelect.style.cursor = 'pointer';
        }
    }
    
    function animateDispense() {
        // Animate item dropping
        itemDisplay.style.transition = 'transform 0.8s ease-in';
        itemDisplay.style.transform = 'translateY(100px)';
        
        // Reset after animation
        setTimeout(() => {
            itemDisplay.style.transition = 'none';
            itemDisplay.style.transform = 'translateY(0)';
        }, 1000);
    }
    
    function animateButton(button) {
        button.style.transform = 'scale(0.95)';
        setTimeout(() => {
            button.style.transform = 'scale(1)';
        }, 150);
    }
    
    function addLogEntry(message, isError = false, isHighlight = false) {
        const entry = document.createElement('div');
        entry.className = 'log-entry';
        
        if (isHighlight) {
            entry.classList.add('highlight');
        }
        
        const timestamp = simulator.cycle;
        entry.textContent = `[${timestamp.toString().padStart(3, '0')}] ${message}`;
        
        if (isError) {
            entry.style.color = '#ef4444';
        }
        
        logContent.appendChild(entry);
        
        // Auto-scroll to bottom
        logContent.scrollTop = logContent.scrollHeight;
        
        // Limit log entries
        if (logContent.children.length > 50) {
            logContent.removeChild(logContent.firstChild);
        }
    }
    
    // ========================================================================
    // Auto-Demo Mode (Optional)
    // ========================================================================
    
    function runDemo() {
        addLogEntry('=== Starting Demo Sequence ===', false, true);
        
        setTimeout(() => {
            simulator.insertCoin5();
            addLogEntry('Demo: Insert ₹5');
        }, 1000);
        
        setTimeout(() => {
            simulator.insertCoin10();
            addLogEntry('Demo: Insert ₹10');
        }, 2500);
        
        setTimeout(() => {
            simulator.selectItem();
            addLogEntry('Demo: Select item');
        }, 4000);
        
        setTimeout(() => {
            addLogEntry('=== Demo Complete ===', false, true);
        }, 6000);
    }
    
    // Uncomment to enable auto-demo on load
    // setTimeout(runDemo, 2000);
    
    // ========================================================================
    // Start Simulation
    // ========================================================================
    
    simulator.start();
    addLogEntry('System initialized - Ready for operation');
    updateButtonStates();
    
    // Initial waveform render
    waveformViewer.render(simulator.getSignalHistory());
    
    // ========================================================================
    // Smooth Scrolling for Navigation
    // ========================================================================
    
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
    
    // ========================================================================
    // Keyboard Shortcuts (for demo presentations)
    // ========================================================================
    
    document.addEventListener('keydown', (e) => {
        if (e.target.tagName === 'INPUT') return; // Don't trigger on input fields
        
        switch(e.key) {
            case '5':
                btnCoin5.click();
                break;
            case '1':
                btnCoin10.click();
                break;
            case 's':
            case 'S':
                btnSelect.click();
                break;
            case 'r':
            case 'R':
                btnReset.click();
                break;
            case 'd':
            case 'D':
                runDemo();
                break;
        }
    });
    
    // Add keyboard shortcuts help
    addLogEntry('Keyboard: [5]=₹5 [1]=₹10 [S]=Select [R]=Reset [D]=Demo');
});
