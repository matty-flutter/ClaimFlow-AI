import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:claimflow_ai/models/claim.dart';
import 'package:claimflow_ai/models/user.dart';

class ClaimService {
  static const String _storageKey = 'claims_data';
  
  Future<List<Claim>> getAllClaims() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    
    if (data == null) {
      final sampleClaims = _getSampleClaims();
      await _saveClaims(sampleClaims);
      return sampleClaims;
    }
    
    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => Claim.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error loading claims: $e');
      final sampleClaims = _getSampleClaims();
      await _saveClaims(sampleClaims);
      return sampleClaims;
    }
  }
  
  Future<Claim?> getClaimById(String id) async {
    final claims = await getAllClaims();
    try {
      return claims.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
  
  Future<void> updateClaim(Claim claim) async {
    final claims = await getAllClaims();
    final index = claims.indexWhere((c) => c.id == claim.id);
    if (index != -1) {
      claims[index] = claim;
      await _saveClaims(claims);
    }
  }
  
  Future<void> _saveClaims(List<Claim> claims) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = claims.map((c) => c.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }
  
  List<Claim> _getSampleClaims() {
    final now = DateTime.now();
    
    final sampleUsers = [
      User(
        id: 'user1',
        name: 'Sarah Johnson',
        email: 'sarah.j@example.com',
        role: 'Claims Adjuster',
        createdAt: now.subtract(const Duration(days: 365)),
        updatedAt: now,
      ),
      User(
        id: 'user2',
        name: 'Michael Chen',
        email: 'michael.c@example.com',
        role: 'Claims Adjuster',
        createdAt: now.subtract(const Duration(days: 365)),
        updatedAt: now,
      ),
      User(
        id: 'user3',
        name: 'Emily Rodriguez',
        email: 'emily.r@example.com',
        role: 'Fraud Analyst',
        createdAt: now.subtract(const Duration(days: 365)),
        updatedAt: now,
      ),
    ];
    
    return [
      Claim(
        id: '1',
        claimNumber: 'AUTO-2024-001234',
        type: 'Auto',
        status: 'Under Review',
        amount: 45000.00,
        description: 'Vehicle collision on Highway 101. Front-end damage, airbags deployed. Driver and passenger minor injuries.',
        claimant: User(
          id: 'claimant1',
          name: 'Robert Williams',
          email: 'robert.w@email.com',
          role: 'Policyholder',
          createdAt: now.subtract(const Duration(days: 180)),
          updatedAt: now,
        ),
        assignedAdjuster: sampleUsers[0],
        incidentDate: now.subtract(const Duration(days: 5)),
        fraudScore: 0.12,
        aiSummary: 'Low-risk claim with consistent evidence. Police report and medical records align with damage assessment.',
        aiRecommendations: [
          'Approve repair estimate from certified body shop',
          'Schedule medical follow-up in 30 days',
          'No fraud indicators detected',
        ],
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      Claim(
        id: '2',
        claimNumber: 'PROP-2024-005678',
        type: 'Property',
        status: 'Approved',
        amount: 125000.00,
        description: 'Fire damage to residential property. Kitchen origin, electrical fault suspected. Significant smoke damage throughout.',
        claimant: User(
          id: 'claimant2',
          name: 'Jennifer Martinez',
          email: 'jennifer.m@email.com',
          role: 'Policyholder',
          createdAt: now.subtract(const Duration(days: 90)),
          updatedAt: now,
        ),
        assignedAdjuster: sampleUsers[1],
        incidentDate: now.subtract(const Duration(days: 15)),
        fraudScore: 0.08,
        aiSummary: 'Fire marshal report confirms electrical origin. Damage assessment matches reported incident timeline.',
        aiRecommendations: [
          'Approved for full restoration',
          'Coordinate with licensed contractors',
          'Schedule final inspection',
        ],
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Claim(
        id: '3',
        claimNumber: 'HEALTH-2024-009012',
        type: 'Health',
        status: 'Pending Documents',
        amount: 85000.00,
        description: 'Emergency surgery following appendicitis. 3-day hospital stay with complications requiring extended care.',
        claimant: User(
          id: 'claimant3',
          name: 'David Thompson',
          email: 'david.t@email.com',
          role: 'Policyholder',
          createdAt: now.subtract(const Duration(days: 200)),
          updatedAt: now,
        ),
        assignedAdjuster: sampleUsers[0],
        incidentDate: now.subtract(const Duration(days: 8)),
        fraudScore: 0.05,
        aiSummary: 'Standard emergency procedure. Medical records complete, awaiting itemized billing from hospital.',
        aiRecommendations: [
          'Request final itemized statement',
          'Verify network provider status',
          'Standard processing timeline applies',
        ],
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(hours: 4)),
      ),
      Claim(
        id: '4',
        claimNumber: 'AUTO-2024-001567',
        type: 'Auto',
        status: 'Investigating',
        amount: 78000.00,
        description: 'Total loss claim following multi-vehicle accident. Conflicting witness statements require investigation.',
        claimant: User(
          id: 'claimant4',
          name: 'Lisa Anderson',
          email: 'lisa.a@email.com',
          role: 'Policyholder',
          createdAt: now.subtract(const Duration(days: 120)),
          updatedAt: now,
        ),
        assignedAdjuster: sampleUsers[2],
        incidentDate: now.subtract(const Duration(days: 3)),
        fraudScore: 0.68,
        aiSummary: 'HIGH ALERT: Multiple fraud indicators detected. Inconsistent timeline, prior claims history, witness discrepancies.',
        aiRecommendations: [
          'Conduct detailed field investigation',
          'Interview all witnesses separately',
          'Review dashcam and traffic camera footage',
          'Cross-reference with prior claim patterns',
        ],
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(minutes: 30)),
      ),
      Claim(
        id: '5',
        claimNumber: 'PROP-2024-006789',
        type: 'Property',
        status: 'Under Review',
        amount: 52000.00,
        description: 'Water damage from burst pipe. Affected basement and first floor. Mold remediation required.',
        claimant: User(
          id: 'claimant5',
          name: 'James Wilson',
          email: 'james.w@email.com',
          role: 'Policyholder',
          createdAt: now.subtract(const Duration(days: 250)),
          updatedAt: now,
        ),
        assignedAdjuster: sampleUsers[1],
        incidentDate: now.subtract(const Duration(days: 12)),
        fraudScore: 0.15,
        aiSummary: 'Property age and maintenance records support claim. Plumber report indicates natural pipe failure.',
        aiRecommendations: [
          'Approve water extraction and drying',
          'Schedule mold inspection',
          'Monitor for additional damage claims',
        ],
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),
      Claim(
        id: '6',
        claimNumber: 'HEALTH-2024-009456',
        type: 'Health',
        status: 'Approved',
        amount: 12000.00,
        description: 'Outpatient knee surgery. Arthroscopic procedure with physical therapy prescribed.',
        claimant: User(
          id: 'claimant6',
          name: 'Maria Garcia',
          email: 'maria.g@email.com',
          role: 'Policyholder',
          createdAt: now.subtract(const Duration(days: 300)),
          updatedAt: now,
        ),
        assignedAdjuster: sampleUsers[0],
        incidentDate: now.subtract(const Duration(days: 20)),
        fraudScore: 0.03,
        aiSummary: 'Pre-approved procedure with in-network surgeon. All documentation complete and verified.',
        aiRecommendations: [
          'Process payment to provider',
          'Authorize 12 physical therapy sessions',
          'Standard case closure',
        ],
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}
