import React, { useEffect, useState } from 'react';
import axios from 'axios';

const EventSummary = () => {
  const [events, setEvents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    axios.get('http://localhost:3000/api/events/admin/summary')
      .then(res => {
        console.log("✅ Event Summary Response:", res.data);
        setEvents(res.data);
        setLoading(false);
      })
      .catch(err => {
        console.error("❌ Error fetching summary:", err.message);
        setError('Failed to load event summary');
        setLoading(false);
      });
  }, []);

  if (loading) return <p>⏳ Loading event summary...</p>;
  if (error) return <p style={{ color: 'red' }}>{error}</p>;

  return (
    <div>
      <h2>📋 Event Summary</h2>

      {events.length === 0 ? (
        <p>⚠️ No events available yet.</p>
      ) : (
        events.map(event => (
          <div key={event._id} style={{ border: '1px solid #ccc', padding: '10px', marginBottom: '1rem' }}>
            <h4>{event.title} ({event.enrolledCount} enrolled)</h4>
            <p>📍 {event.location} | 📅 {event.date}</p>
            <details>
              <summary>See enrolled volunteers</summary>
              {event.enrolledVolunteers.length === 0 ? (
                <p style={{ marginLeft: '1rem' }}>No volunteers enrolled yet.</p>
              ) : (
                <ul>
                  {event.enrolledVolunteers.map(v => (
                    <li key={v._id}>{v.username} ({v.email})</li>
                  ))}
                </ul>
              )}
            </details>
          </div>
        ))
      )}
    </div>
  );
};

export default EventSummary;
