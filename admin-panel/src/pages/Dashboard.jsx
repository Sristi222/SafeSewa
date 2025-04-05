"use client";

import { useEffect, useState } from "react";
import axios from "axios";
import { Spinner } from "react-bootstrap";
import {
  PieChart,
  Pie,
  Cell,
  Tooltip,
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Legend,
  CartesianGrid,
  AreaChart,
  Area,
} from "recharts";
import {
  Users,
  Heart,
  DollarSign,
  AlertCircle,
  ArrowUp,
  ArrowDown,
  Award,
} from "react-feather";

const Dashboard = () => {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [topDonors, setTopDonors] = useState([]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        // Fetch dashboard stats
        const statsRes = await axios.get("http://localhost:3000/api/admin/stats");
        setStats(statsRes.data);

        // Fetch top donors (only successful donations)
        const donorRes = await axios.get("http://localhost:3000/api/admin/top-donations");
        const data = donorRes.data.donations || donorRes.data;

        if (Array.isArray(data)) {
          setTopDonors(data);
        } else {
          console.warn("Invalid top-donations response format");
        }
      } catch (err) {
        console.error("Error loading dashboard data:", err);
        // Fallback mock
        setStats({
          totalUsers: 4558,
          pendingVolunteers: 267,
          pendingFundraisers: 559,
          sosAlerts: 33,
        });
        setTopDonors([]);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const lineData = Array.from({ length: 30 }, (_, i) => ({
    day: i + 1,
    value: Math.floor(Math.random() * 500) + 500,
  }));

  const cards = [
    {
      title: "Total Users",
      value: stats?.totalUsers || 0,
      change: "+12%",
      isPositive: true,
      icon: <Users size={24} />,
      color: "primary",
    },
    {
      title: "Pending Volunteers",
      value: stats?.pendingVolunteers || 0,
      change: "+5%",
      isPositive: true,
      icon: <Heart size={24} />,
      color: "success",
    },
    {
      title: "Pending Fundraisers",
      value: stats?.pendingFundraisers || 0,
      change: "-3%",
      isPositive: false,
      icon: <DollarSign size={24} />,
      color: "warning",
    },
    {
      title: "SOS Alerts",
      value: stats?.sosAlerts || 0,
      change: "+8%",
      isPositive: false,
      icon: <AlertCircle size={24} />,
      color: "danger",
    },
  ];

  const pieData = [
    { name: "Pending Volunteers", value: stats?.pendingVolunteers || 0 },
    { name: "Pending Fundraisers", value: stats?.pendingFundraisers || 0 },
    { name: "SOS Alerts", value: stats?.sosAlerts || 0 },
  ];

  const barData = [
    { name: "Users", value: stats?.totalUsers || 0 },
    { name: "Volunteers", value: stats?.pendingVolunteers || 0 },
    { name: "Fundraisers", value: stats?.pendingFundraisers || 0 },
    { name: "SOS", value: stats?.sosAlerts || 0 },
  ];

  const COLORS = ["#00B3D6", "#333333", "#00B3D6", "#333333"];

  const formatCurrency = (amount, currency = "INR") => {
    const symbols = { USD: "$", EUR: "€", GBP: "£", INR: "₹" };
    return `${symbols[currency] || "₹"}${amount.toLocaleString()}`;
  };

  return (
    <div className="dashboard-container">
      <div className="dashboard-header">
        <h2>Dashboard</h2>
        <div className="dashboard-actions">
          <select className="time-select">
            <option>Last 7 days</option>
            <option>Last 30 days</option>
            <option>Last 90 days</option>
          </select>
          <button className="export-btn">Export Report</button>
        </div>
      </div>

      {loading ? (
        <div className="loading-container">
          <Spinner animation="border" variant="primary" />
          <p>Loading dashboard data...</p>
        </div>
      ) : (
        <>
          {/* Stat Cards */}
          <div className="stats-cards">
            {cards.map((card, index) => (
              <div className={`stat-card ${card.color}`} key={index}>
                <div className="card-icon">{card.icon}</div>
                <div className="card-content">
                  <h3>{card.title}</h3>
                  <div className="card-value-container">
                    <h2>{card.value.toLocaleString()}</h2>
                    <span
                      className={`change-indicator ${card.isPositive ? "positive" : "negative"}`}
                    >
                      {card.isPositive ? <ArrowUp size={14} /> : <ArrowDown size={14} />}
                      {card.change}
                    </span>
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* Charts */}
          <div className="dashboard-charts">
            <div className="chart-container donation-trend">
              <div className="chart-header">
                <h3>Donation Trend</h3>
                <div className="chart-legend">
                  <span className="legend-item">
                    <span className="legend-color" style={{ backgroundColor: "#00B3D6" }}></span>
                    Daily Donations
                  </span>
                </div>
              </div>
              <ResponsiveContainer width="100%" height={250}>
                <AreaChart data={lineData}>
                  <defs>
                    <linearGradient id="colorValue" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#00B3D6" stopOpacity={0.8} />
                      <stop offset="95%" stopColor="#00B3D6" stopOpacity={0.1} />
                    </linearGradient>
                  </defs>
                  <XAxis dataKey="day" />
                  <YAxis />
                  <CartesianGrid strokeDasharray="3 3" />
                  <Tooltip />
                  <Area type="monotone" dataKey="value" stroke="#00B3D6" fill="url(#colorValue)" />
                </AreaChart>
              </ResponsiveContainer>
            </div>

            <div className="chart-container distribution-chart">
              <h3>Distribution</h3>
              <ResponsiveContainer width="100%" height={250}>
                <PieChart>
                  <Pie
                    data={pieData}
                    cx="50%"
                    cy="50%"
                    innerRadius={60}
                    outerRadius={80}
                    paddingAngle={5}
                    dataKey="value"
                  >
                    {pieData.map((entry, index) => (
                      <Cell key={index} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip />
                  <Legend />
                </PieChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Bottom Section */}
          <div className="dashboard-bottom">
            <div className="recent-activities">
              <div className="section-header">
                <h3>Top Donors</h3>
              </div>
              <div className="activities-list">
                {topDonors.length > 0 ? (
                  topDonors.map((donor, idx) => (
                    <div className="activity-item" key={donor._id || idx}>
                      <div className="activity-icon user">
                        <Award size={16} />
                      </div>
                      <div className="activity-details">
                        <h4>{donor.donorName || "Anonymous"}</h4>
                        <p>{donor.fundraiserTitle || "General Donation"}</p>
                      </div>
                      <div className="activity-amount">
                        {formatCurrency(donor.amount, donor.currency)}
                      </div>
                    </div>
                  ))
                ) : (
                  <p>No top donations found</p>
                )}
              </div>
            </div>

            <div className="overview-chart">
              <div className="section-header">
                <h3>Overview</h3>
                <select className="chart-select">
                  <option>This Month</option>
                  <option>Last Month</option>
                  <option>This Year</option>
                </select>
              </div>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={barData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" />
                  <YAxis />
                  <Tooltip />
                  <Bar dataKey="value" fill="#00B3D6" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>
        </>
      )}
    </div>
  );
};

export default Dashboard;
