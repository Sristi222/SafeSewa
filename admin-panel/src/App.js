// App.jsx
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import Dashboard from './pages/Dashboard';
import Users from './pages/Users';
import Volunteers from './pages/Volunteers';
import Donations from './pages/Donation';
import Donationsummary from './pages/DonationSummary';
import AddEvent from './pages/AddEvent';
import EventSummary from './pages/EventSummary';
import Precaution from './pages/DisasterPrecaution';
import Helpline from './pages/HelplineAdmin';


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
              <Link className="nav-link text-white" to="/donations">Approve Donations</Link>
            </li>
            <li className="nav-item">
              <Link className="nav-link text-white" to="/donationsummary">Donation summary</Link>
            </li>
            <li className="nav-item">
              <Link className="nav-link text-white" to="/addevent">Add Events</Link>
            </li>
            <li className="nav-item">
              <Link className="nav-link text-white" to="/eventsummary">Event Summary</Link>
            </li>
            <li className="nav-item">
              <Link className="nav-link text-white" to="/precaution">Precaution</Link>
            </li>
            <li className="nav-item">
              <Link className="nav-link text-white" to="/helpline">Helpline number</Link>
            </li>
          </ul>
        </div>
        <div className="p-4 flex-grow-1">
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/users" element={<Users />} />
            <Route path="/volunteers" element={<Volunteers />} />
            <Route path="/donations" element={<Donations />} />
            <Route path="/donationsummary" element={<Donationsummary />} />
            <Route path="/addevent" element={<AddEvent />} />
            <Route path="/eventsummary" element={<EventSummary />} />
            <Route path="/precaution" element={<Precaution />} />
            <Route path="/helpline" element={<Helpline />} />


          </Routes>
        </div>
      </div>
    </Router>
  );
}

export default App;
