"use client"

import { useEffect, useState, useCallback } from "react"
import axios from "axios"
import { Spinner } from "react-bootstrap"
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
} from "recharts"
import { Users, Heart, DollarSign, AlertCircle, ArrowUp, ArrowDown, RefreshCw } from "react-feather"

const Dashboard = () => {
  const [stats, setStats] = useState(null)
  const [loading, setLoading] = useState(true)
  const [topDonations, setTopDonations] = useState([])
  const [lineData, setLineData] = useState([])
  const [donationsLoading, setDonationsLoading] = useState(false)
  const [error, setError] = useState(null)

  // Function to fetch top donations
  const fetchTopDonations = useCallback(async () => {
    setDonationsLoading(true)
    setError(null)
    
    try {
      // Use the correct API endpoint for your backend
      const response = await axios.get("http://localhost:3000/api/admin/top-donations")
      
      // Check the structure of your API response and adjust accordingly
      const donationsData = response.data.donations || response.data
      
      if (Array.isArray(donationsData)) {
        setTopDonations(donationsData)
      } else {
        console.error("Unexpected API response format:", response.data)
        setError("Invalid data format received from server")
      }
    } catch (err) {
      console.error("Error fetching top donations:", err)
      setError("Failed to load donation data. Please try again.")
    } finally {
      setDonationsLoading(false)
    }
  }, [])

  // Function to fetch all dashboard data
  const fetchDashboardData = useCallback(async () => {
    setLoading(true)
    
    try {
      // Fetch dashboard stats
      const statsResponse = await axios.get("http://localhost:3000/api/admin/stats")
      setStats(statsResponse.data)
      
      // Fetch donation trends
      const trendsResponse = await axios.get("http://localhost:3000/api/admin/donation-trends")
      if (trendsResponse.data && Array.isArray(trendsResponse.data)) {
        setLineData(trendsResponse.data)
      }
      
      // Fetch top donations
      await fetchTopDonations()
      
    } catch (err) {
      console.error("Error fetching dashboard data:", err)
    } finally {
      setLoading(false)
    }
  }, [fetchTopDonations])

  useEffect(() => {
    fetchDashboardData()
    
    // Optional: Set up polling to refresh donation data periodically
    const refreshInterval = setInterval(() => {
      fetchTopDonations()
    }, 60000) // Refresh every minute
    
    return () => clearInterval(refreshInterval)
  }, [fetchDashboardData, fetchTopDonations])

  // Cards data
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
  ]

  const pieData = [
    { name: "Pending Volunteers", value: stats?.pendingVolunteers || 0 },
    { name: "Pending Fundraisers", value: stats?.pendingFundraisers || 0 },
    { name: "SOS Alerts", value: stats?.sosAlerts || 0 },
  ]

  const barData = [
    {
      name: "Users",
      value: stats?.totalUsers || 0,
    },
    {
      name: "Volunteers",
      value: stats?.pendingVolunteers || 0,
    },
    {
      name: "Fundraisers",
      value: stats?.pendingFundraisers || 0,
    },
    {
      name: "SOS",
      value: stats?.sosAlerts || 0,
    },
  ]

  // Using SafeSewa brand colors
  const COLORS = ["#00B3D6", "#333333", "#00B3D6", "#333333"]

  // Handle manual refresh of donation data
  const handleRefreshDonations = () => {
    fetchTopDonations()
  }

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
          <div className="stats-cards">
            {cards.map((card, index) => (
              <div className={`stat-card ${card.color}`} key={index}>
                <div className="card-icon">{card.icon}</div>
                <div className="card-content">
                  <h3>{card.title}</h3>
                  <div className="card-value-container">
                    <h2>{card.value.toLocaleString()}</h2>
                    <span className={`change-indicator ${card.isPositive ? "positive" : "negative"}`}>
                      {card.isPositive ? <ArrowUp size={14} /> : <ArrowDown size={14} />}
                      {card.change}
                    </span>
                  </div>
                </div>
              </div>
            ))}
          </div>

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
                <AreaChart data={lineData} margin={{ top: 10, right: 30, left: 0, bottom: 0 }}>
                  <defs>
                    <linearGradient id="colorValue" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#00B3D6" stopOpacity={0.8} />
                      <stop offset="95%" stopColor="#00B3D6" stopOpacity={0.1} />
                    </linearGradient>
                  </defs>
                  <XAxis dataKey="day" tick={{ fontSize: 12 }} />
                  <YAxis tick={{ fontSize: 12 }} />
                  <CartesianGrid strokeDasharray="3 3" vertical={false} />
                  <Tooltip />
                  <Area type="monotone" dataKey="value" stroke="#00B3D6" fillOpacity={1} fill="url(#colorValue)" />
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
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip />
                  <Legend />
                </PieChart>
              </ResponsiveContainer>
            </div>
          </div>

          <div className="dashboard-bottom">
            <div className="recent-activities">
              <div className="section-header">
                <h3>Top Donations</h3>
                <button 
                  className="refresh-btn" 
                  onClick={handleRefreshDonations} 
                  disabled={donationsLoading}
                >
                  {donationsLoading ? (
                    <Spinner animation="border" size="sm" />
                  ) : (
                    <RefreshCw size={14} />
                  )}
                  <span>Refresh</span>
                </button>
              </div>
              
              {donationsLoading ? (
                <div className="loading-donations">
                  <Spinner animation="border" size="sm" />
                  <span>Refreshing donations...</span>
                </div>
              ) : error ? (
                <div className="error-message">
                  <p>{error}</p>
                  <button onClick={handleRefreshDonations} className="retry-btn">
                    Try Again
                  </button>
                </div>
              ) : (
                <div className="activities-list">
                  {topDonations.length > 0 ? (
                    topDonations.map((donation) => (
                      <div className="activity-item" key={donation.id || donation._id}>
                        <div className="activity-icon fundraiser">
                          <DollarSign size={16} />
                        </div>
                        <div className="activity-details">
                          <h4>{donation.donorName}</h4>
                          <p>{donation.fundraiserTitle}</p>
                          <small>{donation.date || new Date(donation.createdAt).toLocaleDateString()}</small>
                        </div>
                        <div className="activity-amount">₹{donation.amount.toLocaleString()}</div>
                      </div>
                    ))
                  ) : (
                    <div className="no-data-message">
                      <p>No donation data available</p>
                    </div>
                  )}
                </div>
              )}
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
                <BarChart data={barData} margin={{ top: 20, right: 30, left: 20, bottom: 5 }}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} />
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
  )
}

export default Dashboard
