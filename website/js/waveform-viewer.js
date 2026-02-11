// ============================================================================
// Waveform Viewer - Real-Time Signal Display
// ============================================================================
// Renders live digital waveforms on HTML5 Canvas, similar to an oscilloscope
// or waveform viewer like GTKWave.
// ============================================================================

class WaveformViewer {
    constructor(canvasId) {
        this.canvas = document.getElementById(canvasId);
        this.ctx = this.canvas.getContext('2d');
        
        // Canvas dimensions
        this.width = this.canvas.width;
        this.height = this.canvas.height;
        
        // Waveform configuration
        this.signalHeight = 30;
        this.signalPadding = 10;
        this.timeScale = 20; // pixels per clock cycle
        this.scrollOffset = 0;
        
        // Signal colors
        this.colors = {
            clk: '#10b981',
            coin5: '#8b5cf6',
            coin10: '#f59e0b',
            coin20: '#8b5cf6',
            coin50: '#ec4899',
            select: '#3b82f6',
            dispense: '#ef4444',
            returnChange: '#fbbf24',
            state: '#06b6d4',
            credit: '#10b981',
            grid: '#1e293b',
            text: '#94a3b8',
            high: '#10b981',
            low: '#334155'
        };
        
        // Signal definitions
        this.signals = [
            { name: 'clk', type: 'digital', color: this.colors.clk },
            { name: 'coin10', type: 'digital', color: this.colors.coin10 },
            { name: 'coin20', type: 'digital', color: this.colors.coin20 },
            { name: 'coin50', type: 'digital', color: this.colors.coin50 },
            { name: 'select', type: 'digital', color: this.colors.select },
            { name: 'state', type: 'bus', color: this.colors.state },
            { name: 'credit', type: 'bus', color: this.colors.credit },
            { name: 'dispense', type: 'digital', color: this.colors.dispense },
            { name: 'returnChange', type: 'digital', color: this.colors.returnChange }
        ];
        
        this.stateNames = ['IDLE', 'ACCEPT', 'WAIT', 'DISPENSE', 'CHANGE'];
    }
    
    // ========================================================================
    // Main Render Function
    // ========================================================================
    render(signalHistory) {
        if (!signalHistory || signalHistory.length === 0) {
            this.drawEmpty();
            return;
        }
        
        // Clear canvas
        this.ctx.fillStyle = '#0a0e1a';
        this.ctx.fillRect(0, 0, this.width, this.height);
        
        // Draw grid
        this.drawGrid(signalHistory.length);
        
        // Draw each signal
        let yOffset = 40;
        
        for (const signal of this.signals) {
            this.drawSignal(signal, signalHistory, yOffset);
            yOffset += this.signalHeight + this.signalPadding;
        }
        
        // Draw time markers
        this.drawTimeMarkers(signalHistory.length);
    }
    
    // ========================================================================
    // Draw Grid Background
    // ========================================================================
    drawGrid(cycles) {
        this.ctx.strokeStyle = this.colors.grid;
        this.ctx.lineWidth = 1;
        
        // Vertical grid lines (every 5 cycles)
        for (let i = 0; i <= cycles; i += 5) {
            const x = i * this.timeScale + 60;
            this.ctx.beginPath();
            this.ctx.moveTo(x, 0);
            this.ctx.lineTo(x, this.height);
            this.ctx.stroke();
        }
        
        // Horizontal grid lines (between signals)
        let y = 40;
        for (let i = 0; i < this.signals.length; i++) {
            this.ctx.beginPath();
            this.ctx.moveTo(0, y);
            this.ctx.lineTo(this.width, y);
            this.ctx.stroke();
            y += this.signalHeight + this.signalPadding;
        }
    }
    
    // ========================================================================
    // Draw Individual Signal
    // ========================================================================
    drawSignal(signal, history, yOffset) {
        // Draw signal name
        this.ctx.fillStyle = this.colors.text;
        this.ctx.font = '12px monospace';
        this.ctx.textAlign = 'right';
        this.ctx.fillText(signal.name, 55, yOffset + this.signalHeight / 2 + 4);
        
        // Draw waveform
        this.ctx.strokeStyle = signal.color;
        this.ctx.lineWidth = 2;
        this.ctx.beginPath();
        
        for (let i = 0; i < history.length; i++) {
            const data = history[i];
            const x = i * this.timeScale + 60;
            const value = this.getSignalValue(signal.name, data);
            
            if (signal.type === 'digital') {
                this.drawDigitalSegment(x, yOffset, value, i === 0);
            } else if (signal.type === 'bus') {
                this.drawBusSegment(x, yOffset, value, signal.name, i === 0);
            }
        }
        
        this.ctx.stroke();
    }
    
    // ========================================================================
    // Get Signal Value from History Data
    // ========================================================================
    getSignalValue(signalName, data) {
        switch (signalName) {
            case 'clk':
                return data.clk;
            case 'coin10':
                return data.coin10;
            case 'coin20':
                return data.coin20;
            case 'coin50':
                return data.coin50;
            case 'select':
                return data.select;
            case 'dispense':
                return data.dispense;
            case 'returnChange':
                return data.returnChange;
            case 'state':
                return data.state;
            case 'credit':
                return data.credit;
            default:
                return false;
        }
    }
    
    // ========================================================================
    // Draw Digital Signal Segment
    // ========================================================================
    drawDigitalSegment(x, yOffset, value, isFirst) {
        const high = yOffset + 5;
        const low = yOffset + this.signalHeight - 5;
        const y = value ? high : low;
        
        if (isFirst) {
            this.ctx.moveTo(x, y);
        } else {
            // Draw vertical edge if value changed
            const prevY = this.ctx.lineWidth;
            this.ctx.lineTo(x, y);
        }
        
        this.ctx.lineTo(x + this.timeScale, y);
    }
    
    // ========================================================================
    // Draw Bus Signal Segment
    // ========================================================================
    drawBusSegment(x, yOffset, value, signalName, isFirst) {
        const high = yOffset + 5;
        const low = yOffset + this.signalHeight - 5;
        const mid = yOffset + this.signalHeight / 2;
        
        if (!isFirst) {
            // Draw transition marker (/)
            this.ctx.lineTo(x, low);
            this.ctx.lineTo(x + 3, high);
        }
        
        // Draw high and low lines
        this.ctx.moveTo(x + (isFirst ? 0 : 3), high);
        this.ctx.lineTo(x + this.timeScale - 3, high);
        
        this.ctx.moveTo(x + (isFirst ? 0 : 3), low);
        this.ctx.lineTo(x + this.timeScale - 3, low);
        
        // Draw value text
        this.ctx.fillStyle = this.colors.text;
        this.ctx.font = '10px monospace';
        this.ctx.textAlign = 'center';
        
        let displayValue;
        if (signalName === 'state') {
            displayValue = this.stateNames[value] || value;
        } else if (signalName === 'credit') {
            displayValue = `₹${value}`;
        } else {
            displayValue = value.toString(16).toUpperCase();
        }
        
        this.ctx.fillText(displayValue, x + this.timeScale / 2, mid + 4);
        
        // Continue for next segment
        this.ctx.strokeStyle = this.signals.find(s => s.name === signalName).color;
        this.ctx.moveTo(x + this.timeScale - 3, high);
    }
    
    // ========================================================================
    // Draw Time Markers
    // ========================================================================
    drawTimeMarkers(cycles) {
        this.ctx.fillStyle = this.colors.text;
        this.ctx.font = '11px monospace';
        this.ctx.textAlign = 'center';
        
        for (let i = 0; i <= cycles; i += 5) {
            const x = i * this.timeScale + 60;
            this.ctx.fillText(i.toString(), x, 15);
        }
        
        // Draw "Clock Cycle" label
        this.ctx.textAlign = 'left';
        this.ctx.fillText('Cycle:', 5, 15);
    }
    
    // ========================================================================
    // Draw Empty State
    // ========================================================================
    drawEmpty() {
        this.ctx.fillStyle = '#0a0e1a';
        this.ctx.fillRect(0, 0, this.width, this.height);
        
        this.ctx.fillStyle = this.colors.text;
        this.ctx.font = '16px monospace';
        this.ctx.textAlign = 'center';
        this.ctx.fillText('Waiting for simulation data...', this.width / 2, this.height / 2);
    }
}

// Export for use in main controller
if (typeof module !== 'undefined' && module.exports) {
    module.exports = WaveformViewer;
}
