import React, { useState, useRef } from 'react';
import { useWorkers } from '../hooks/useSupabase';
import { Camera, X, RefreshCw, CheckCircle2 } from 'lucide-react';
import { useTranslation } from '../context/LanguageContext';

interface QRScannerProps {
  isOpen: boolean;
  onClose: () => void;
  onScanSuccess: (workerId: string) => void;
}

export const QRScanner: React.FC<QRScannerProps> = ({ isOpen, onClose, onScanSuccess }) => {
  const { data: workers } = useWorkers();
  const { t } = useTranslation();
  const [simulatedWorker, setSimulatedWorker] = useState('');
  const [success, setSuccess] = useState(false);
  const [isScanning, setIsScanning] = useState(false);

  if (!isOpen) return null;

  const handleSimulateScan = () => {
    if (!simulatedWorker) return;
    setIsScanning(true);
    
    setTimeout(() => {
      setIsScanning(false);
      setSuccess(true);
      
      // Complete scan after delay
      setTimeout(() => {
        onScanSuccess(simulatedWorker);
        setSuccess(false);
        setSimulatedWorker('');
        onClose();
      }, 1000);
    }, 1200);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/85 backdrop-blur-sm p-4">
      <div className="relative w-full max-w-md bg-zinc-900 border border-zinc-800 rounded-3xl overflow-hidden shadow-2xl p-6 text-center">
        {/* Close Button */}
        <button
          onClick={onClose}
          className="absolute top-4 right-4 p-2 text-zinc-400 hover:text-white rounded-full bg-zinc-850 transition-colors"
        >
          <X size={20} />
        </button>

        <h3 className="text-xl font-bold text-white mb-2">{t('scanQrCode')}</h3>
        <p className="text-sm text-zinc-400 mb-6">
          Scan the QR card printed on the worker's Rojgar Card.
        </p>

        {/* Scan Frame */}
        <div className="relative w-64 h-64 mx-auto mb-8 bg-zinc-950 border-2 border-zinc-800 rounded-2xl flex flex-col items-center justify-center overflow-hidden">
          {isScanning && (
            <div className="absolute inset-0 bg-green-500/10 flex items-center justify-center">
              {/* Laser scanner line animation */}
              <div className="absolute left-0 right-0 h-1 bg-green-400 shadow-md shadow-green-500/80 animate-bounce w-full" style={{ animationDuration: '2s' }} />
              <RefreshCw className="animate-spin text-green-400" size={32} />
            </div>
          )}

          {success && (
            <div className="absolute inset-0 bg-green-500 flex flex-col items-center justify-center text-white animate-fade-in">
              <CheckCircle2 size={48} className="mb-2 animate-scale-in" />
              <span className="font-bold text-sm">{t('scanSuccess')}</span>
            </div>
          )}

          {!isScanning && !success && (
            <>
              {/* Scanner Grid Mock */}
              <div className="absolute inset-4 border border-zinc-700/30 rounded-lg flex items-center justify-center">
                <Camera size={44} className="text-zinc-600 animate-pulse" />
              </div>
              
              {/* Corner brackets */}
              <div className="absolute top-2 left-2 w-6 h-6 border-t-4 border-l-4 border-green-500 rounded-tl-md" />
              <div className="absolute top-2 right-2 w-6 h-6 border-t-4 border-r-4 border-green-500 rounded-tr-md" />
              <div className="absolute bottom-2 left-2 w-6 h-6 border-b-4 border-l-4 border-green-500 rounded-bl-md" />
              <div className="absolute bottom-2 right-2 w-6 h-6 border-b-4 border-r-4 border-green-500 rounded-br-md" />
            </>
          )}
        </div>

        {/* Simulation / Fallback Form */}
        <div className="bg-zinc-850 p-4 rounded-2xl border border-zinc-800 text-left">
          <label className="block text-xs font-bold text-zinc-400 uppercase tracking-wider mb-2">
            Simulate QR Reader (Sandbox Mode)
          </label>
          <div className="flex gap-2">
            <select
              value={simulatedWorker}
              onChange={e => setSimulatedWorker(e.target.value)}
              className="flex-1 bg-zinc-800 border border-zinc-700 text-white text-sm rounded-xl px-3 py-2 focus:ring-2 focus:ring-green-500 focus:outline-none"
            >
              <option value="">-- Choose Worker --</option>
              {workers?.map(w => (
                <option key={w.id} value={w.id}>
                  {w.full_name} ({w.worker_code || 'No Code'})
                </option>
              ))}
            </select>
            <button
              onClick={handleSimulateScan}
              disabled={!simulatedWorker || isScanning || success}
              className="px-4 py-2 bg-green-600 text-white text-sm font-bold rounded-xl hover:bg-green-500 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Scan
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
