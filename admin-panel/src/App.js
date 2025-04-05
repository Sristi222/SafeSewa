import { BrowserRouter as Router, Routes, Route, NavLink } from "react-router-dom"
import Dashboard from "./pages/Dashboard"
import Users from "./pages/Users"
import Volunteers from "./pages/Volunteers"
import Donations from "./pages/Donation"
import Donationsummary from "./pages/DonationSummary"
import AddEvent from "./pages/AddEvent"
import EventSummary from "./pages/EventSummary"
import Precaution from "./pages/DisasterPrecaution"
import Helpline from "./pages/HelplineAdmin"
import FundraiserDetails from "./pages/DonationFundreaiser Details"
import logo from './assets/Logo1.png'; // adjust path based on actual file location
import {
  Home,
  Users as UsersIcon,
  Heart,
  DollarSign,
  BarChart2,
  Calendar,
  AlertTriangle,
  Phone,
  PlusCircle,
  LogOut,
} from "react-feather"

import "bootstrap/dist/css/bootstrap.min.css"
import "./App.css"

function App() {
  return (
    <Router>
      <div className="app-container">
        <div className="sidebar">
          <div className="sidebar-header">
            <div className="logo">
            <img src={logo} alt="SafeSewa Logo" className="logo-img" />
              <h4>SafeSewa</h4>
            </div>
            <div className="admin-profile">
              <div className="admin-avatar">
                <span>A</span>
              </div>
              <div className="admin-info">
                <h5>Admin Panel</h5>
              </div>
            </div>
          </div>

          <ul className="nav-menu">
            <li className="nav-item">
              <NavLink className={({ isActive }) => (isActive ? "nav-link active" : "nav-link")} to="/">
                <Home size={18} />
                <span>Admin Dashboard</span>
              </NavLink>
            </li>
            <li className="nav-item">
              <NavLink className={({ isActive }) => (isActive ? "nav-link active" : "nav-link")} to="/users">
                <UsersIcon size={18} />
                <span>Users</span>
              </NavLink>
            </li>
            <li className="nav-item">
              <NavLink className={({ isActive }) => (isActive ? "nav-link active" : "nav-link")} to="/volunteers">
                <Heart size={18} />
                <span>Volunteers</span>
              </NavLink>
            </li>
            <li className="nav-item">
              <NavLink className={({ isActive }) => (isActive ? "nav-link active" : "nav-link")} to="/donations">
                <DollarSign size={18} />
                <span>Approve Donations</span>
              </NavLink>
            </li>
            <li className="nav-item">
              <NavLink className={({ isActive }) => (isActive ? "nav-link active" : "nav-link")} to="/donationsummary">
                <BarChart2 size={18} />
                <span>Donation Summary</span>
              </NavLink>
            </li>
            <li className="nav-item">
              <NavLink
                className={({ isActive }) => (isActive ? "nav-link active" : "nav-link")}
                to="/fundraiserdetails"
              >
                <DollarSign size={18} />
                <span>Fundraiser Details</span>
              </NavLink>
            </li>
            <li className="nav-item">
              <NavLink className={({ isActive }) => (isActive ? "nav-link active" : "nav-link")} to="/addevent">
                <PlusCircle size={18} />
                <span>Add Events</span>
              </NavLink>
            </li>
            <li className="nav-item">
              <NavLink className={({ isActive }) => (isActive ? "nav-link active" : "nav-link")} to="/eventsummary">
                <Calendar size={18} />
                <span>Event Summary</span>
              </NavLink>
            </li>
            <li className="nav-item">
              <NavLink className={({ isActive }) => (isActive ? "nav-link active" : "nav-link")} to="/precaution">
                <AlertTriangle size={18} />
                <span>Precaution</span>
              </NavLink>
            </li>
            <li className="nav-item">
              <NavLink className={({ isActive }) => (isActive ? "nav-link active" : "nav-link")} to="/helpline">
                <Phone size={18} />
                <span>Helpline Number</span>
              </NavLink>
            </li>
          </ul>

          <div className="sidebar-footer">
            <button className="sign-out-btn">
              <LogOut size={18} />
              <span>Sign Out</span>
            </button>
          </div>
        </div>

        <div className="content-area">
          <div className="top-bar">
            <div className="search-container">
              <input type="text" placeholder="Search..." className="search-input" />
            </div>
            <div className="top-bar-actions">
              <button className="notification-btn">
                <span className="notification-badge">3</span>🔔
              </button>
              <div className="user-profile">
                <div className="avatar-placeholder">
                  <span>A</span>
                </div>
              </div>
            </div>
          </div>

          <div className="main-content">
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
              <Route path="/fundraiserdetails" element={<FundraiserDetails />} />
            </Routes>
          </div>
        </div>
      </div>
    </Router>
  )
}

export default App

