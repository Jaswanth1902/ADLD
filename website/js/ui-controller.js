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
    // Application State
    // ========================================================================
    const items = [
        { name: 'Milkshake', cost: 15, icon: '🥤' },
        { name: 'Chips', cost: 20, icon: '🍟' },
        { name: 'Chocolate', cost: 25, icon: '🍫' },
        { name: 'Juice', cost: 30, icon: '🧃' },
        { name: 'Coffee', cost: 50, icon: '☕' }
    ];
    
    let currentItemIndex = 0;
    
    // ========================================================================
    // DOM Elements
    // ========================================================================
    const btnCoin10 = document.getElementById('btn-coin-10');
    const btnCoin20 = document.getElementById('btn-coin-20');
    const btnCoin50 = document.getElementById('btn-coin-50');
    const btnSelect = document.getElementById('btn-select');
    const btnReset = document.getElementById('btn-reset');
    
    const prevItemBtn = document.getElementById('prev-item');
    const nextItemBtn = document.getElementById('next-item');
    const itemIconDisplay = document.getElementById('item-icon');
    const itemNameDisplay = document.getElementById('item-name');
    const itemCostDisplay = document.querySelector('.item-cost .value');
    
    const creditDisplay = document.getElementById('credit-value');
    const statusText = document.getElementById('status-text');
    const statusLED = document.getElementById('status-led');
    const cycleCount = document.getElementById('cycle-count');
    const clockState = document.getElementById('clock-state');
    const changeIndicator = document.getElementById('change-indicator');
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
    // Initialization
    // ========================================================================
    
    function init() {
        updateItemDisplay();
        simulator.start();
        addLogEntry('System initialized - Ready for operation');
        updateButtonStates();
        
        // Initial waveform render
        waveformViewer.render(simulator.getSignalHistory());
    }

    // ========================================================================
    // Event Handlers
    // ========================================================================
    
    btnCoin10.addEventListener('click', () => {
        simulator.insertCoin10();
        addLogEntry('₹10 coin inserted');
        animateButton(btnCoin10);
    });
    
    btnCoin20.addEventListener('click', () => {
        simulator.insertCoin20();
        addLogEntry('₹20 coin inserted');
        animateButton(btnCoin20);
    });
    
    btnCoin50.addEventListener('click', () => {
        simulator.insertCoin50();
        addLogEntry('₹50 coin inserted');
        animateButton(btnCoin50);
    });
    
    btnSelect.addEventListener('click', () => {
        const cost = items[currentItemIndex].cost;
        if (simulator.getCredit() >= cost) {
            simulator.selectItem();
            addLogEntry(`Item "${items[currentItemIndex].name}" selected`);
            animateButton(btnSelect);
        } else {
            addLogEntry(`Insufficient credit! Need ₹${cost}`, true);
        }
    });
    
    btnReset.addEventListener('click', () => {
        simulator.reset();
        addLogEntry('System reset', true);
        changeIndicator.textContent = '-';
        resetItemAnimation();
        animateButton(btnReset);
    });
    
    prevItemBtn.addEventListener('click', () => {
        currentItemIndex = (currentItemIndex - 1 + items.length) % items.length;
        updateItemDisplay();
        animateNavButton(prevItemBtn);
    });
    
    nextItemBtn.addEventListener('click', () => {
        currentItemIndex = (currentItemIndex + 1) % items.length;
        updateItemDisplay();
        animateNavButton(nextItemBtn);
    });
    
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
        addLogEntry(`✓ ${items[currentItemIndex].name} dispensed!`, false, true);
    };
    
    simulator.onReturnChange = (change) => {
        changeIndicator.textContent = `₹${change}`;
        addLogEntry(`✓ Change returned: ₹${change}`, false, true);
        
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
    
    function updateItemDisplay() {
        const item = items[currentItemIndex];
        
        // Update DOM
        itemIconDisplay.textContent = item.icon;
        itemNameDisplay.textContent = item.name;
        itemCostDisplay.textContent = `₹${item.cost}`;
        
        // Update Simulator Cost
        simulator.setItemCost(item.cost);
        
        // Update Button States (if credit is now sufficient for cheaper item)
        updateButtonStates();
        
        // visual feedback
        itemIconDisplay.style.transform = 'scale(0.8) rotate(-5deg)';
        setTimeout(() => {
            itemIconDisplay.style.transform = 'scale(1) rotate(0deg)';
        }, 200);
    }
    
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
        const cost = items[currentItemIndex].cost;
        
        // Disable select button if insufficient credit
        if (credit < cost) {
            btnSelect.style.opacity = '0.5';
            btnSelect.style.cursor = 'not-allowed';
        } else {
            btnSelect.style.opacity = '1';
            btnSelect.style.cursor = 'pointer';
        }
    }
    
    function animateDispense() {
        // Animate item dropping
        itemIconDisplay.classList.add('dispensing');
        
        // Reset after animation
        setTimeout(() => {
            itemIconDisplay.classList.remove('dispensing');
            // itemIconDisplay.style.transform = 'translateY(0)';
        }, 1000);
    }
    
    function resetItemAnimation() {
        itemIconDisplay.classList.remove('dispensing');
        itemIconDisplay.style.transform = 'translateY(0)';
    }
    
    function animateButton(button) {
        // Button animation handled largely by CSS active states, but we can add JS effect if needed
        // For now, rely on CSS transform/shadow
    }
    
    function animateNavButton(button) {
         button.style.transform = 'scale(0.9)';
         setTimeout(() => {
             button.style.transform = '';
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
        
        // Demo for Chips (20) using two 10s
        if (items[currentItemIndex].name !== 'Chips') {
             // Find chips
             const chipsIndex = items.findIndex(i => i.name === 'Chips');
             if (chipsIndex !== -1) {
                 currentItemIndex = chipsIndex;
                 updateItemDisplay();
                 addLogEntry('Demo: Switched to Chips (₹20)');
             }
        }
        
        setTimeout(() => {
            simulator.insertCoin10();
            addLogEntry('Demo: Insert ₹10');
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
            case '1':
                btnCoin10.click();
                break;
            case '2':
                btnCoin20.click();
                break;
            case '5':
                btnCoin50.click();
                break;
            case 'ArrowLeft':
                prevItemBtn.click();
                break;
            case 'ArrowRight':
                nextItemBtn.click();
                break;
            case 's':
            case 'S':
            case 'Enter':
                btnSelect.click();
                break;
            case 'r':
            case 'R':
            case 'Backspace':
                btnReset.click();
                break;
            case 'd':
            case 'D':
                runDemo();
                break;
        }
    });
    
    // Add keyboard shortcuts help
    addLogEntry('Keys: [1]=10 [2]=20 [5]=50 [Arrows]=Item [S]=Select [R]=Reset');

    // Run Initialization
    init();
});
