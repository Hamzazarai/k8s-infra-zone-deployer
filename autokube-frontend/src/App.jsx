import { useState, useEffect } from 'react';
import { Server, Cpu, HardDrive, Network, Play, Settings, Monitor, Database, Shield, RefreshCw } from 'lucide-react';

const AutoKube = () => {
  const [formData, setFormData] = useState({
    zone_name: '',
    provider_type: 'proxmox',
    proxmox_node: '',
    api_url: '',
    api_user: '',
    api_password: '',
    base_template: '',
    storage_pool: '',
    internal_bridge: '',
    external_bridge: '',
    gateway: '',
    nat_network_cidr: '10.0.0.0/24',
    master_count: 3,
    worker_count: 3,
    master_cpu: 4,
    master_ram: 8,
    master_disk: 50,
    worker_cpu: 8,
    worker_ram: 16,
    worker_disk: 100,
    ci_user: '',
    ci_password: '',
    vm_ips: {}
  });

  const [isDeploying, setIsDeploying] = useState(false);
  const [deploymentLogs, setDeploymentLogs] = useState([]);
  const [currentPhase, setCurrentPhase] = useState('');
  const [vms, setVms] = useState({ masters: {}, workers: {}, others: {} });
  const [backendStatus, setBackendStatus] = useState('disconnected');

  // Backend API base URL - adjust this to your backend URL
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || "http://localhost:8000";

  // Check backend connectivity on component mount
  useEffect(() => {
    checkBackendConnection();
    loadExistingVMs();
  }, []);

  const checkBackendConnection = async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/vms`);
      if (response.ok) {
        setBackendStatus('connected');
      } else {
        setBackendStatus('error');
      }
    } catch (error) {
      setBackendStatus('disconnected');
      console.error('Backend connection failed:', error);
    }
  };

  const loadExistingVMs = async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/vms`);
      if (response.ok) {
        const data = await response.json();
        if (data.status === 'success') {
          setVms({
            masters: data.masters || {},
            workers: data.workers || {},
            others: data.others || {}
          });
        }
      }
    } catch (error) {
      console.error('Failed to load existing VMs:', error);
    }
  };

  const handleInputChange = (field, value) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));
  };

  const deployToBackend = async () => {
    setIsDeploying(true);
    setDeploymentLogs([]);
    setCurrentPhase('Connecting to backend...');

    try {
      // Send the payload exactly as your VMConfig model expects
      const payload = {
        zone_name: formData.zone_name,
        provider_type: formData.provider_type,
        proxmox_node: formData.proxmox_node,
        api_url: formData.api_url,
        api_user: formData.api_user,
        api_password: formData.api_password,
        base_template: formData.base_template,
        storage_pool: formData.storage_pool,
        internal_bridge: formData.internal_bridge,
        external_bridge: formData.external_bridge || null,
        gateway: formData.gateway,
        nat_network_cidr: formData.nat_network_cidr,
        master_count: formData.master_count,
        worker_count: formData.worker_count,
        master_cpu: formData.master_cpu,
        master_ram: formData.master_ram,
        master_disk: formData.master_disk,
        worker_cpu: formData.worker_cpu,
        worker_ram: formData.worker_ram,
        worker_disk: formData.worker_disk,
        ci_user: formData.ci_user,
        ci_password: formData.ci_password,
        vm_ips: formData.vm_ips
      };

      setDeploymentLogs(prev => [...prev, '📡 Sending configuration to backend...']);
      setCurrentPhase('Deploying infrastructure...');

      const response = await fetch(`${API_BASE_URL}/deploy`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(payload)
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.detail || 'Deployment failed');
      }

      const result = await response.json();
      
      setDeploymentLogs(prev => [
        ...prev, 
        '✅ Configuration sent successfully',
        `📄 Terraform vars: ${result.tfvars_file}`,
        `📋 Ansible inventory: ${result.hosts_ini_file}`,
        `📝 Deployment log: ${result.log_file}`
      ]);
      
      setCurrentPhase('Deployment initiated successfully');
      
      // Refresh VM list after deployment
      setTimeout(() => {
        loadExistingVMs();
      }, 2000);

    } catch (error) {
      setDeploymentLogs(prev => [
        ...prev, 
        `❌ Error: ${error.message}`
      ]);
      setCurrentPhase('Deployment failed');
      console.error('Deployment error:', error);
    } finally {
      setIsDeploying(false);
    }
  };

  const handleSubmit = () => {
    if (backendStatus !== 'connected') {
      setDeploymentLogs(['❌ Backend is not connected. Please check your API server.']);
      return;
    }
    deployToBackend();
  };

  const totalResources = {
    vms: 3 + formData.master_count + formData.worker_count,
    cpu: formData.master_count * formData.master_cpu + formData.worker_count * formData.worker_cpu + 8,
    ram: formData.master_count * formData.master_ram + formData.worker_count * formData.worker_ram + 24,
    disk: formData.master_count * formData.master_disk + formData.worker_count * formData.worker_disk + 200
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'connected': return 'text-green-400';
      case 'disconnected': return 'text-red-400';
      case 'error': return 'text-yellow-400';
      default: return 'text-gray-400';
    }
  };

  const getStatusText = (status) => {
    switch (status) {
      case 'connected': return '● Connected';
      case 'disconnected': return '● Disconnected';
      case 'error': return '● Error';
      default: return '● Unknown';
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 p-6">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="text-center mb-12">
          <div className="flex items-center justify-center gap-3 mb-4">
            <div className="p-3 bg-blue-500 rounded-xl">
              <Server className="w-8 h-8 text-white" />
            </div>
            <h1 className="text-5xl font-bold text-white">AutoKube</h1>
          </div>
          <p className="text-xl text-slate-300">
            Dynamic Kubernetes Infrastructure Deployment on Proxmox
          </p>
          
          {/* Backend Status */}
          <div className="mt-4 flex items-center justify-center gap-4">
            <span className={`text-sm font-medium ${getStatusColor(backendStatus)}`}>
              Backend: {getStatusText(backendStatus)}
            </span>
            <button
              onClick={checkBackendConnection}
              className="text-slate-400 hover:text-white transition-colors"
              title="Refresh connection status"
            >
              <RefreshCw className="w-4 h-4" />
            </button>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Configuration Form */}
          <div className="lg:col-span-2">
            <div className="bg-white/10 backdrop-blur-lg border border-white/20 rounded-2xl p-8">
              <h2 className="text-2xl font-bold text-white mb-6 flex items-center gap-2">
                <Settings className="w-6 h-6" />
                Infrastructure Configuration
              </h2>

              <div className="space-y-8">
                {/* Proxmox Configuration */}
                <div className="bg-orange-500/10 border border-orange-500/20 rounded-xl p-6">
                  <h3 className="text-lg font-semibold text-white mb-4 flex items-center gap-2">
                    <Server className="w-5 h-5 text-orange-400" />
                    Proxmox Configuration
                  </h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2">Zone Name</label>
                      <input
                        type="text"
                        value={formData.zone_name}
                        onChange={(e) => handleInputChange('zone_name', e.target.value)}
                        className="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-orange-500"
                        placeholder="my-k8s-zone"
                        required
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2">Proxmox Node</label>
                      <input
                        type="text"
                        value={formData.proxmox_node}
                        onChange={(e) => handleInputChange('proxmox_node', e.target.value)}
                        className="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-orange-500"
                        placeholder="proxmox-node1"
                        required
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2">API URL</label>
                      <input
                        type="url"
                        value={formData.api_url}
                        onChange={(e) => handleInputChange('api_url', e.target.value)}
                        className="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-orange-500"
                        placeholder="https://proxmox.example.com:8006/api2/json"
                        required
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2">API User</label>
                      <input
                        type="text"
                        value={formData.api_user}
                        onChange={(e) => handleInputChange('api_user', e.target.value)}
                        className="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-orange-500"
                        placeholder="root@pam"
                        required
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2">API Password</label>
                      <input
                        type="password"
                        value={formData.api_password}
                        onChange={(e) => handleInputChange('api_password', e.target.value)}
                        className="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-orange-500"
                        placeholder="••••••••"
                        required
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2">Base Template</label>
                      <input
                        type="text"
                        value={formData.base_template}
                        onChange={(e) => handleInputChange('base_template', e.target.value)}
                        className="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-orange-500"
                        placeholder="ubuntu-22.04-template"
                        required
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2">Storage Pool</label>
                      <input
                        type="text"
                        value={formData.storage_pool}
                        onChange={(e) => handleInputChange('storage_pool', e.target.value)}
                        className="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-orange-500"
                        placeholder="local-lvm"
                        required
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2">Internal Bridge</label>
                      <input
                        type="text"
                        value={formData.internal_bridge}
                        onChange={(e) => handleInputChange('internal_bridge', e.target.value)}
                        className="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-orange-500"
                        placeholder="vmbr0"
                        required
                      />
                    </div>
                  </div>
                </div>

                {/* Network Configuration */}
                <div className="bg-purple-500/10 border border-purple-500/20 rounded-xl p-6">
                  <h3 className="text-lg font-semibold text-white mb-4 flex items-center gap-2">
                    <Network className="w-5 h-5 text-purple-400" />
                    Network Configuration
                  </h3>
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2">External Bridge (Optional)</label>
                      <input
                        type="text"
                        value={formData.external_bridge}
                        onChange={(e) => handleInputChange('external_bridge', e.target.value)}
                        className="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-purple-500"
                        placeholder="vmbr1"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2">Gateway IP</label>
                      <input
                        type="text"
                        value={formData.gateway}
                        onChange={(e) => handleInputChange('gateway', e.target.value)}
                        className="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-purple-500"
                        placeholder="10.0.0.1"
                        required
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2">NAT Network CIDR</label>
                      <input
                        type="text"
                        value={formData.nat_network_cidr}
                        onChange={(e) => handleInputChange('nat_network_cidr', e.target.value)}
                        className="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-purple-500"
                        placeholder="10.0.0.0/24"
                        required
                      />
                    </div>
                  </div>
                </div>

                {/* Cloud-Init Configuration */}
                <div className="bg-gray-500/10 border border-gray-500/20 rounded-xl p-6">
                  <h3 className="text-lg font-semibold text-white mb-4 flex items-center gap-2">
                    <Settings className="w-5 h-5 text-gray-400" />
                    Cloud-Init Configuration
                  </h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2"> ser</label>
                      <input
                        type="text"
                        value={formData.ci_user}
                        onChange={(e) => handleInputChange('ci_user', e.target.value)}
                        className="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-gray-500"
                        placeholder="ubuntu"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2">CI Password</label>
                      <input
                        type="password"
                        value={formData.ci_password}
                        onChange={(e) => handleInputChange('ci_password', e.target.value)}
                        className="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-gray-500"
                        placeholder="••••••••"
                      />
                    </div>
                  </div>
                </div>

                {/* Masters Configuration */}
                <div className="bg-blue-500/10 border border-blue-500/20 rounded-xl p-6">
                  <h3 className="text-lg font-semibold text-white mb-4 flex items-center gap-2">
                    <Server className="w-5 h-5 text-blue-400" />
                    Kubernetes Masters
                  </h3>
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2">Count</label>
                      <input
                        type="number"
                        min="1"
                        max="5"
                        value={formData.master_count}
                        onChange={(e) => handleInputChange('master_count', parseInt(e.target.value))}
                        className="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2">
                        <Cpu className="inline w-4 h-4 mr-1" />
                        CPU
                      </label>
                      <input
                        type="number"
                        min="2"
                        max="16"
                        value={formData.master_cpu}
                        onChange={(e) => handleInputChange('master_cpu', parseInt(e.target.value))}
                        className="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2">RAM (GB)</label>
                      <input
                        type="number"
                        min="4"
                        max="64"
                        value={formData.master_ram}
                        onChange={(e) => handleInputChange('master_ram', parseInt(e.target.value))}
                        className="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2">
                        <HardDrive className="inline w-4 h-4 mr-1" />
                        Disk (GB)
                      </label>
                      <input
                        type="number"
                        min="20"
                        max="500"
                        value={formData.master_disk}
                        onChange={(e) => handleInputChange('master_disk', parseInt(e.target.value))}
                        className="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
                      />
                    </div>
                  </div>
                </div>

                {/* Workers Configuration */}
                <div className="bg-green-500/10 border border-green-500/20 rounded-xl p-6">
                  <h3 className="text-lg font-semibold text-white mb-4 flex items-center gap-2">
                    <Server className="w-5 h-5 text-green-400" />
                    Kubernetes Workers
                  </h3>
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2">Count</label>
                      <input
                        type="number"
                        min="1"
                        max="10"
                        value={formData.worker_count}
                        onChange={(e) => handleInputChange('worker_count', parseInt(e.target.value))}
                        className="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-green-500"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2">
                        <Cpu className="inline w-4 h-4 mr-1" />
                        CPU
                      </label>
                      <input
                        type="number"
                        min="2"
                        max="32"
                        value={formData.worker_cpu}
                        onChange={(e) => handleInputChange('worker_cpu', parseInt(e.target.value))}
                        className="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-green-500"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2">RAM (GB)</label>
                      <input
                        type="number"
                        min="4"
                        max="128"
                        value={formData.worker_ram}
                        onChange={(e) => handleInputChange('worker_ram', parseInt(e.target.value))}
                        className="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-green-500"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2">
                        <HardDrive className="inline w-4 h-4 mr-1" />
                        Disk (GB)
                      </label>
                      <input
                        type="number"
                        min="50"
                        max="1000"
                        value={formData.worker_disk}
                        onChange={(e) => handleInputChange('worker_disk', parseInt(e.target.value))}
                        className="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-green-500"
                      />
                    </div>
                  </div>
                </div>

                {/* Deploy Button */}
                <button
                  onClick={handleSubmit}
                  disabled={isDeploying || !formData.zone_name || !formData.proxmox_node || !formData.api_url || backendStatus !== 'connected'}
                  className="w-full bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 disabled:from-gray-600 disabled:to-gray-700 text-white font-semibold py-4 px-6 rounded-xl transition-all duration-200 flex items-center justify-center gap-2 text-lg"
                >
                  {isDeploying ? (
                    <>
                      <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
                      Deploying...
                    </>
                  ) : (
                    <>
                      <Play className="w-5 h-5" />
                      {backendStatus === 'connected' ? 'Deploy Kubernetes Infrastructure' : 'Backend Disconnected'}
                    </>
                  )}
                </button>
              </div>
            </div>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Resource Summary */}
            <div className="bg-white/10 backdrop-blur-lg border border-white/20 rounded-2xl p-6">
              <h3 className="text-xl font-bold text-white mb-4 flex items-center gap-2">
                <Monitor className="w-5 h-5" />
                Resource Summary
              </h3>
              <div className="space-y-3">
                <div className="flex justify-between items-center">
                  <span className="text-slate-300">Total VMs</span>
                  <span className="text-white font-semibold">{totalResources.vms}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-slate-300">Total CPU</span>
                  <span className="text-white font-semibold">{totalResources.cpu} cores</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-slate-300">Total RAM</span>
                  <span className="text-white font-semibold">{totalResources.ram} GB</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-slate-300">Total Disk</span>
                  <span className="text-white font-semibold">{totalResources.disk} GB</span>
                </div>
              </div>
            </div>

            {/* Deployed VMs */}
            {Object.keys(vms.masters).length > 0 || Object.keys(vms.workers).length > 0 || Object.keys(vms.others).length > 0 ? (
              <div className="bg-white/10 backdrop-blur-lg border border-white/20 rounded-2xl p-6">
                <h3 className="text-xl font-bold text-white mb-4 flex items-center gap-2">
                  <Server className="w-5 h-5" />
                  Deployed VMs
                  <button
                    onClick={loadExistingVMs}
                    className="ml-auto text-slate-400 hover:text-white transition-colors"
                    title="Refresh VM list"
                  >
                    <RefreshCw className="w-4 h-4" />
                  </button>
                </h3>
                <div className="space-y-4">
                  {Object.keys(vms.masters).length > 0 && (
                    <div>
                      <h4 className="text-blue-400 font-semibold mb-2">Masters</h4>
                      <div className="space-y-1">
                        {Object.entries(vms.masters).map(([name, ip]) => (
                          <div key={name} className="flex justify-between text-sm">
                            <span className="text-slate-300">{name}</span>
                            <span className="text-white">{ip}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                  
                  {Object.keys(vms.workers).length > 0 && (
                    <div>
                      <h4 className="text-green-400 font-semibold mb-2">Workers</h4>
                      <div className="space-y-1">
                        {Object.entries(vms.workers).map(([name, ip]) => (
                          <div key={name} className="flex justify-between text-sm">
                            <span className="text-slate-300">{name}</span>
                            <span className="text-white">{ip}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                  
                  {Object.keys(vms.others).length > 0 && (
                    <div>
                      <h4 className="text-purple-400 font-semibold mb-2">Infrastructure</h4>
                      <div className="space-y-1">
                        {Object.entries(vms.others).map(([name, ip]) => (
                          <div key={name} className="flex justify-between text-sm">
                            <span className="text-slate-300">{name}</span>
                            <span className="text-white">{ip}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              </div>
            ) : (
              <div className="bg-white/10 backdrop-blur-lg border border-white/20 rounded-2xl p-6">
                <h3 className="text-xl font-bold text-white mb-4">Infrastructure Components</h3>
                <div className="space-y-3">
                  <div className="flex items-center gap-3 text-slate-300">
                    <Network className="w-4 h-4 text-blue-400" />
                    <span>HAProxy Load Balancer</span>
                  </div>
                  <div className="flex items-center gap-3 text-slate-300">
                    <Database className="w-4 h-4 text-green-400" />
                    <span>NFS Storage (10.0.0.88)</span>
                  </div>
                  <div className="flex items-center gap-3 text-slate-300">
                    <Shield className="w-4 h-4 text-orange-400" />
                    <span>Harbor Registry (10.0.0.77)</span>
                  </div>
                  <div className="flex items-center gap-3 text-slate-300">
                    <Monitor className="w-4 h-4 text-purple-400" />
                    <span>Prometheus + Grafana</span>
                  </div>
                  <div className="flex items-center gap-3 text-slate-300">
                    <Server className="w-4 h-4 text-yellow-400" />
                    <span>JupyterHub (HA)</span>
                  </div>
                </div>
              </div>
            )}

            {/* Deployment Logs */}
            {(isDeploying || deploymentLogs.length > 0) && (
              <div className="bg-black/30 backdrop-blur-lg border border-white/20 rounded-2xl p-6">
                <h3 className="text-xl font-bold text-white mb-4">Deployment Status</h3>
                {currentPhase && (
                  <div className="mb-4 p-3 bg-blue-500/20 border border-blue-500/30 rounded-lg">
                    <span className="text-blue-300 font-medium">Current Phase: {currentPhase}</span>
                  </div>
                )}
                <div className="space-y-2 max-h-64 overflow-y-auto">
                  {deploymentLogs.map((log, index) => (
                    <div key={index} className="text-sm text-green-300 font-mono">
                      {log}
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default AutoKube;