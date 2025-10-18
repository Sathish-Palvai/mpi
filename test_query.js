#!/usr/bin/env node

const fetch = require('node-fetch');

async function testQuery() {
  try {
    console.log('Testing participant query for 1R85...');
    
    const response = await fetch('http://localhost:3000/api/participants/query', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        participantName: '1R85'
      }),
    });

    const data = await response.json();
    
    console.log('\n=== RESPONSE RECEIVED ===');
    console.log('Status:', response.status);
    console.log('Response data:', JSON.stringify(data, null, 2));
    
    // Extract participant data
    const participant = data?.RegistrationData?.RegistrationSubmit?.Participant;
    if (participant) {
      console.log('\n=== PARTICIPANT DATA ===');
      console.log('ParticipantName:', participant['@ParticipantName']);
      console.log('CompanyShortName:', participant['@CompanyShortName']);
      console.log('CompanyLongName:', participant['@CompanyLongName']);
      console.log('PhonePart1:', participant['@PhonePart1']);
      console.log('PhonePart2:', participant['@PhonePart2']);
      console.log('PhonePart3:', participant['@PhonePart3']);
      console.log('StartDate:', participant['@StartDate']);
    } else {
      console.log('\n❌ No participant data found in response');
    }

  } catch (error) {
    console.error('❌ Error testing query:', error.message);
  }
}

testQuery();