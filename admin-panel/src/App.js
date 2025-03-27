// App.jsx
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import Dashboard from './pages/Dashboard';
import Users from './pages/Users';
import Volunteers from './pages/Volunteers';
import Donations from './pages/Donation';
import SOSAlerts from './pages/SOSAlerts';
import 'bootstrap/dist/css/bootstrap.min.css';
import './App.css';

function App() {
  return (
    <Router>
      <div className="d-flex">
        <div className="bg-dark text-white p-3 vh-100" style={{ width: '220px' }}>
          <h4 className="text-white">Admin Panel</h4>
          <ul className="nav flex-column mt-4">
            <li className="nav-item">
              <Link className="nav-link text-white" to="/">Dashboard</Link>
            </li>
            <li className="nav-item">
              <Link className="nav-link text-white" to="/users">Users</Link>
            </li>
            <li className="nav-item">
              <Link className="nav-link text-white" to="/volunteers">Volunteers</Link>
            </li>
            <li className="nav-item">
              <Link className="nav-link text-white" to="/donations">Donations</Link>
            </li>
            <li className="nav-item">
              <Link className="nav-link text-white" to="/sos-alerts">SOS Alerts</Link>
            </li>
          </ul>
        </div>
        <div className="p-4 flex-grow-1">
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/users" element={<Users />} />
            <Route path="/volunteers" element={<Volunteers />} />
            <Route path="/donations" element={<Donations />} />
            <Route path="/sos-alerts" element={<SOSAlerts />} />
          </Routes>
        </div>
      </div>
    </Router>
  );
}

export default App;
