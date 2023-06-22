const projectDetails = {
  hasProjectEndDate: {
    question: '1.1b Does the project have an end date?'
  },
  projectStartDate: {
    question: '1.1a Project start date'
  },
  projectEndDate: {
    question: '1.1c Project end date'
  },
  countries: {
    question: '1.2 What country/countries is the site located in?'
  },
  siteArea: {
    question: '1.3 What is the overall site area?'
  }
}

const siteBackground = {
  stakeholders: {
    question: '2.1 Which stakeholders are involved in the project activities?',
    options: [
      'Local community representatives',
      'Local leaders',
      'Indigenous peoples',
      'Traditionally marginalised or underrepresented groups',
      'Landowners/customary area owners',
      'National, central or federal government',
      'Sub-national, regional or state government',
      'Local or municipal government',
      'Overseas government agencies ',
      'Intergovernmental agencies',
      'Managed area manager/personnel',
      'International or national NGO',
      'Small-scale local NGO',
      'Community based organisations, associations or cooperatives',
      'Industry/Private sector',
      'Academic institute or research facility',
      'Ecotourists',
      'Unknown',
      'Other'
    ]
  },
  managementStatus: {
    question:
      '2.2 What was the management status of the site immediately before the project started?',
    options: [
      'Protected informally at a local level',
      'Protection is formally recognized at the state/province/regional level',
      'Protection is formally recognized at a national level',
      'Protection is formally recognized at an international level',
      'None',
      'Unknown'
    ]
  },
  lawStatus: {
    question:
      '2.3 Are management activities at the site recognized in statutory or customary laws?',
    options: [
      'Yes - statutory',
      'Yes - customary',
      'No',
      'Partially - statutory',
      'Partially - customary'
    ]
  },
  managementArea: {
    question: '2.4 Name of the formal management area the site is contained within (if relevant)?'
  },
  protectionStatus: {
    question:
      '2.5 How would you describe the protection status of the site immediately before the project started?',
    options: ['Full protection', 'Partial protection', 'Sustainable use', 'No management']
  },
  areStakeholdersInvolved: {
    question:
      '2.6 Are the stakeholders involved in project activities able to influence site management rules?',
    options: ['Yes', 'No', 'Partially']
  },
  governmentArrangement: {
    question:
      '2.7 What best describes the governance arrangement of the site immediately before the project started?',
    options: [
      'Governance by government',
      'Shared governance',
      'Private governance',
      'Governance by indigenous peoples and local communities',
      'Mixed governance',
      'None',
      'Unknown'
    ]
  },
  landTenure: {
    question: '2.8 What was the land tenure of the site immediately before the project started?',
    options: [
      'Private - individual',
      'Private - business',
      'Customary',
      'Communal',
      'Sub-national or local government',
      'National government',
      'Unknown'
    ]
  },
  customaryRights: {
    question: '2.9 Are customary rights to land within the site recognised in national law?',
    options: ['Yes', 'No', 'Partially']
  }
}

const restorationAims = {
  nestedStakeholderBenefitsRanking: {
    question: 'Please rank the importance of the aims to the stakeholders below.',
    options: ['Primary aims', 'Co-benefits', 'Neither']
  },
  ecologicalAims: {
    question: '3.1 What are the ecological aim(s) of the project activities at the site?',
    options: [
      'Increase mangrove area',
      'Improve mangrove condition/halt or reduce degradation',
      'Increase mangrove species richness',
      'Offset mangrove loss from another area',
      'Habitat protection',
      'Increase native fauna/wildlife',
      'Increase native flora/vegetation (non-mangrove)',
      'Reduce invasive species',
      'Increase ecological resilience',
      'Increase habitat connectivity',
      'Restore hydrological connectivity',
      'Improve sediment dynamics',
      'Improve nutrient cycling',
      'Increase carbon storage and sequestration',
      'None',
      'Unknown'
    ]
  },
  socioEconomicAims: {
    question: '3.2 What are the socio-economic aim(s) of project activities at the site?',
    options: [
      'Enhance fisheries/restore fishing grounds',
      'Provide sustainable timber resources',
      'Provide sustainable non-timber products ',
      'Improve water quality',
      'Prevent or ameliorate pollution',
      'Coastal storm or flood protection',
      'Erosion control or coastal stability',
      'Carbon offsets/trading',
      'Tourism and recreation',
      'Land reclamation',
      'Generate employment and income',
      "Promote women's equal representation and participation in employment",
      'Safeguard cultural or spiritual importance',
      'Safeguard traditional practises',
      'Increase food security',
      'Secure management rights and land tenure',
      'Improve local community health',
      'Coastal beautification or aesthetic value',
      'Support local community natural resource management institutions',
      'Encourage community involvement',
      'Education/raise environmental awareness',
      'Sustainable financing',
      'None',
      'Unknown'
    ]
  },
  otherAims: {
    question: '3.3 What are the other aim(s) of project activities at the site?',
    options: [
      'Have site designated as a protected area',
      'Meet international commitments/national targets',
      'Influence government policy',
      'Improve restoration techniques',
      'Answer scientific research questions',
      'None'
    ]
  }
}

const causesOfDecline = {
  lossKnown: {
    question: '4.1 Is the cause(s) of mangrove loss or degradation at the site known?'
  },
  causesOfDecline: {
    question: '4.2 What were the major cause(s) of mangrove loss or degradation at the site?'
  },
  levelsOfDegredation: {
    question:
      '4.3 Rate the magnitude of impact of the cause(s) of decline selected in the previous question, on mangrove loss and degradation - High, Moderate, Low',
    options: ['High', 'Moderate', 'Low']
  }
}

const preRestorationAssessment = {
  mangrovesPreviouslyOccured: {
    question: '5.1 Have mangroves naturally occurred at the site previously?',
    options: ['Yes', 'No', 'Unknown']
  },
  mangroveRestorationAttempted: {
    question: '5.2 Has mangrove restoration/rehabilitation been attempted at the site previously?',
    options: ['Yes', 'No', 'Unknown']
  },
  lastRestorationAttemptYear: {
    question: '5.2a What year was restoration/rehabilitation last attempted at the site?'
  },
  previousBiophysicalInterventions: {
    question: '5.2b What biophysical interventions were previously attempted at the site?',
    options: [
      'Restore hydrology - excavate channels',
      'Restore hydrology - remove or breach aquaculture pond walls',
      'Restore hydrology - clear channel blockages',
      'Restore hydrology - reconnection of upstream flows restricted by dams or road crossings.',
      'Trap sediments (e.g., fence barriers)',
      'Reduce wave energy (e.g., bamboo walls, offshore reefs, breakwaters)',
      'Reprofile and change the elevation of the soil, relative to sea level',
      'Activities to reduce salinity',
      'Exclusion fences',
      'Vegetation clearance and suppression',
      'Remove debris',
      'Remove seaweed or algae from seedlings',
      'Remove excess sand/sediment ',
      'Planting',
      'Broadcast collected propagules onto an incoming tide',
      'Large scale broadcasting of propagules from the air or boats',
      'Assisted natural regeneration ',
      'None',
      'Unknown'
    ]
  },
  whyUnsuccessfulRestorationAttempt: {
    question:
      '5.2c If the last restoration/rehabilitation attempt was unsuccessful, please specify why this was the case?',
    options: [
      'Location not suitable for any mangroves',
      'Location not suitable for species used ',
      'Competition from invasive species',
      'Damage from pests or wild animals',
      'Barnacle/oyster infestations',
      'Plant diseases',
      'Livestock grazing',
      'Storm damage to mangrove trees and their seedlings ',
      'Extreme climatic events',
      'Erosion due to waves or flooding',
      'Refuse dumped on restoration site',
      'Surrounding land use impacting the site',
      'Exploitation for resources',
      'Original cause of loss/degradation not addressed',
      'Change in governmental/legislative support ',
      'Weak/unsupportive tenure arrangement ',
      'Weak/unsupportive management rights',
      'Weak local natural resource governance institutions',
      'Lack of sustainable financing mechanism in place',
      'Poor stakeholder participation and engagement',
      'Poor benefit distribution',
      'Unknown '
    ]
  },
  siteAssessmentBeforeProject: {
    question: '5.3 Was the site assessed before the current project activities were started?',
    options: ['Yes', 'No', 'Unknown']
  },
  siteAssessmentType: {
    question: '5.3a How was the assessment undertaken?',
    options: ['Field assessment', 'Remote assessment']
  },
  referenceSite: {
    question: '5.3b Has the site been compared to a reference site?',
    options: ['Yes', 'No', 'Unknown']
  },
  lostMangrovesYear: {
    question: '5.3c What year were mangroves lost from this site?'
  },
  naturalRegenerationAtSite: {
    question: '5.3d Is natural regeneration apparent at the site?',
    options: ['No', 'Mangroves have established', 'Mangroves have established and grown']
  },
  mangroveSpeciesPresent: {
    question: '5.3e What mangrove species were present at the site?',
    options: ['Unknown']
  },
  speciesComposition: {
    question: '5.3f What was the species composition of mangroves at the site?'
  },
  physicalMeasurementsTaken: {
    question: '5.3g What physical site measurements were taken?',
    options: [
      'Tidal range (cm)',
      'Elevation relative to mean sea level (cm)',
      'Water salinity (ppt)',
      'Soil pore water salinity (ppt)',
      'Water pH',
      'Soil pore water pH',
      'Soil type',
      'Soil organic matter'
    ]
  },
  pilotTestConducted: {
    question: '5.4 Was a pilot/test intervention conducted?',
    options: ['Yes', 'No', 'Unknown']
  },
  guidanceForSiteRestoration: {
    question: '5.5 Was external expertise or guidance consulted on how to best restore the site?',
    options: [
      'Yes, external expertise and written guidance',
      'Yes, external expertise only',
      'Yes, written guidance only',
      'No',
      'Unknown'
    ]
  }
}

const siteInterventions = {
  whichStakeholdersInvolved: {
    question: '6.1 Which stakeholders undertook the project activities at the site? ',
    options: [
      'Local community representatives',
      'Local leaders',
      'Indigenous peoples',
      'Traditionally marginalised or underrepresented groups',
      'Landowners/customary area owners',
      'National, central or federal government',
      'Sub-national, regional or state government',
      'Local or municipal government',
      'Overseas government agencies ',
      'Intergovernmental agencies',
      'Managed area manager/personnel',
      'International or national NGO',
      'Small-scale local NGO',
      'Community based organisations, associations or cooperatives',
      'Industry/Private sector',
      'Academic institute or research facility',
      'Ecotourists',
      'Unknown'
    ]
  },
  biophysicalInterventionsUsed: {
    question: '6.2 What biophysical interventions were used to restore/rehabilitate the site?',
    options: [
      'Restore hydrology - excavate channels',
      'Restore hydrology - remove or breach aquaculture pond walls',
      'Restore hydrology - clear channel blockages',
      'Restore hydrology - reconnection of upstream flows restricted by dams, road crossings etc.',
      'Trap sediments (e.g., with fence barriers)',
      'Reduce wave energy (e.g., bamboo walls, offshore reefs, breakwaters)',
      'Reprofile and change the elevation of the soil, relative to sea level',
      'Activities to reduce salinity',
      'Exclusion fences',
      'Vegetation clearance and suppression',
      'Remove debris',
      'Remove seaweed or algae from seedlings',
      'Remove excess sand/sediment ',
      'Planting',
      'Broadcast collected propagules onto an incoming tide',
      'Large scale broadcasting of propagules from the air or boats',
      'Assisted natural regeneration ',
      'None'
    ]
  },
  biophysicalInterventionDuration: {
    question: '6.2a What was the duration of the biophysical interventions?',
    options: ['Intervention start date', 'Intervention end date']
  },
  mangroveSpeciesUsed: {
    question: '6.2b What mangrove species were used?'
  },
  sourceOfMangroves: {
    question: 'What was the source of seeds/propagules or seedlings?'
  },
  mangroveAssociatedSpecies: {
    question: '6.2c Were mangrove-associated species planted?',
    options: [
      'Species',
      'Number',
      'Source:Nursery ,Wild, Both',
      'Purpose: ,Coastal defence  ,Source of food ,Products for sale  ,Traditional medicines ,Other ,Not applicable'
    ]
  },
  localParticipantTraining: {
    question: '6.3 Did local participants receive restoration training?',
    options: ['Yes', 'No', 'Unknown']
  },
  organizationsProvidingTraining: {
    question: '6.3a What type of organisations provided the restoration training?',
    options: [
      'Local community representatives',
      'Local leaders',
      'Indigenous peoples',
      'Traditionally marginalised or underrepresented groups',
      'Landowners/customary area owners',
      'National, central or federal government',
      'Sub-national, regional or state government',
      'Local or municipal government',
      'Overseas government agencies ',
      'Intergovernmental agencies',
      'Managed area manager/personnel',
      'International or national NGO',
      'Small-scale local NGO',
      'Community based organisations, associations or cooperatives',
      'Industry/Private sector',
      'Academic institute or research facility',
      'Ecotourists',
      'Unknown'
    ]
  },
  otherActivitiesImplemented: {
    question:
      '6.4 Were there other activities implemented to address the causes of decline at the site?',
    options: [
      'Livelihood activities',
      'Securing tenure arrangement ',
      'Management activities ',
      'Strengthening mangrove governance ',
      'Environmental education',
      'Formal mangrove protection ',
      'Training and capacity building',
      'None'
    ]
  }
}

const costs = {
  supportForActivities: {
    question:
      '7.1 What type of support was provided for the project activities conducted at the site?',
    options: ['Monetary', 'Voluntary/Non-monetary']
  },
  projectInterventionFunding: {
    question:
      '7.2 What is the main finance mechanism used to fund the project interventions at the site?',
    options: [
      'Grant based ',
      'Debt/Equity ',
      'Market ',
      'Fiscal ',
      'Risk management ',
      'Regulatory ',
      'Unknown',
      'Other'
    ]
  },
  projectFunderNames: {
    question: '7.3 What funders provided monetary support? ',
    options: [
      'Members of local community',
      'Indigenous peoples',
      'Landowners/customary area owners',
      'National, central or federal government',
      'Sub-national, regional or state government',
      'Local or municipal government',
      'Overseas government agencies ',
      'Intergovernmental agencies',
      'Managed area manager/personnel',
      'International or national NGO',
      'Small-scale local NGO',
      'Community based organisations, associations or cooperatives',
      'Industry/Private sector',
      'Academic institute or research facility',
      'Ecotourists',
      'Unknown',
      'Other',
      'Percentage'
    ]
  },
  costOfProjectActivities: {
    question: '7.4 What was the total cost of the project activities at the site?',
    options: ['Total Cost', 'Amount ', 'Currency']
  },
  breakdownOfCost: {
    question: '7.5 What was the breakdown of the costs of the project activities?',
    options: [
      'Project planning & management',
      'Amount ',
      'Currency',
      'Biophysical interventions',
      'Amount ',
      'Currency',
      'Community activities',
      'Amount ',
      'Currency',
      'Site maintenance',
      'Amount ',
      'Currency',
      'Monitoring',
      'Amount ',
      'Currency',
      'Other costs',
      'Amount ',
      'Currency'
    ]
  },
  percentageSplitOfActivities: {
    question:
      '7.5a What was the approximate percentage split in expenditure between the different biophysical interventions and/or community activities?'
  },
  nonmonetisedContributions: {
    question:
      '7.6 What non-monetised contributions were made to the project activities at the site?',
    options: ['Volunteer labour', 'Knowledge or expertise', 'Equipment ', 'Land', 'Unknown']
  }
}

const managementStatusAndEffectiveness = {
  dateOfAssessment: {
    question: '8.1 What date was this management status and effectiveness assessment conducted?'
  },
  stakeholderManagement: {
    question: '8.2 Which stakeholders currently manage the site?',
    options: [
      'Local community representatives',
      'Local leaders',
      'Indigenous peoples',
      'Traditionally marginalised or underrepresented groups Landowners/customary area owners',
      'National, central or federal government',
      'Sub-national, regional or state government',
      'Local or municipal government',
      'Overseas government agencies ',
      'Intergovernmental agencies',
      'Managed area manager/personnel',
      'International or national NGO',
      'Local NGO',
      'Community based organisations, associations or cooperatives',
      'Industry/Private sector',
      'Academic institute or research facility',
      'Ecotourists',
      'Unknown'
    ]
  },
  stakeholderInfluence: {
    question:
      '8.3 Are these stakeholders involved in the project activities able to influence management rules at the site?',
    options: ['Yes', 'No', 'Partially']
  },
  managementStatusChanges: {
    question:
      '8.4 Has any aspect of the management status of the site changed since the start of the project activities?',
    options: ['Yes', 'No']
  },
  currentManagementStatus: {
    question: '8.4a What is the current management status of the site?',
    options: [
      'Protected informally at a local level',
      'Protection is formally recognized at the state/province/regional level',
      'Protection is formally recognized at a national level',
      'Protection is formally recognized at an international level',
      'None',
      'Unknown'
    ]
  },
  managementLaws: {
    question:
      '8.4b Are management activities at the site recognized in statutory or customary laws?',
    options: [
      'Yes - statutory ',
      'Yes - customary ',
      'No',
      'Partially – statutory',
      'Partially - customary'
    ]
  },
  nameOfFormalManagementArea: {
    question: '8.4c Name of the formal management area the site is contained within (if relevant)?'
  },
  projectStatusChange: {
    question:
      '8.5 Has the protected status of the site changed since the start of the project activities?',
    options: ['Yes', 'No']
  },
  currentProtectionStatus: {
    question: '8.5a How would you currently describe the protection status of the site?',
    options: ['Full protection', 'Partially protected', 'Sustainable use', 'No management']
  },
  financeForCiteManagement: {
    question: '8.6 What is the main finance mechanism used to fund ongoing site management?',
    options: [
      'Grant based ',
      'Debt/Equity ',
      'Market ',
      'Fiscal ',
      'Risk management ',
      'Regulatory ',
      'Unknown',
      'Other'
    ]
  },
  sufficientFunds: {
    question:
      '8.7 Is the current budget or funds used to support on-going management activities at the site sufficient?',
    options: [
      'There is no budget or funds for on-going management',
      'The available budget or funds is inadequate for basic management needs and presents a serious constraint to the capacity to manage the site',
      'The available budget or funds is acceptable but could be further increased to fully achieve effective management',
      'The available budget or funds is sufficient and meets the full management needs of the site',
      'Unknown'
    ]
  },
  resourcesToEnforceRegulations: {
    question:
      '8.8 Do those responsible for on-going management at the site (e.g., staff, community associations, management groups) have sufficient capacity and resources to enforce the rules and regulations?',
    options: [
      'Those with responsibility for managing the site do not have the capacity to enforce the rules and regulations',
      'Those with responsibility for managing the site can only partially enforce the rules and regulations',
      'Those with responsibility for managing the site can adequately enforce the rules and regulations',
      'Those with responsibility for managing the site can fully enforce the rules and regulations',
      'Unknown'
    ]
  },
  equitableSharingOfSiteBenefits: {
    question:
      '8.9 Is there an effective strategy or approach for ensuring benefits from the site are shared equitably among local stakeholders?',
    options: [
      'There is no strategy or approach for equitable benefit sharing among the relevant stakeholders',
      'A strategy or approach for equitable benefit sharing is being prepared ',
      'A strategy or approach for equitable benefit sharing has been prepared but not implemented',
      'A strategy or approach for equitable benefit sharing is being partially implemented',
      'A strategy or approach for equitable benefit sharing is being fully implemented',
      'Unknown'
    ]
  },
  climateChangeAdaptation: {
    question: '8.10 Is the site consciously managed to adapt to climate change?',
    options: [
      'There have been no efforts or plans to consider adaptation to climate change management',
      'Some initial thought has taken place about current and anticipated impacts of climate change, but this has yet to be translated into management plans',
      'Limited plans have been drawn up about how to adapt management to current and anticipated climate change, which may or may not be implemented',
      'Detailed plans have been drawn up about how to adapt management to current and anticipated climate change, and these are already being implemented',
      'Unknown'
    ]
  }
}

const socioeconomicGovernanceStatusOutcomes = {
  dateOfOutcomesAssessment: {
    question:
      '9.1 What date was this socioeconomic and governance status and outcomes assessment conducted?'
  },
  changeInGovernance: {
    question:
      '9.2 Has the governance arrangement of the site changed since the start of the project activities?',
    options: ['Yes', 'No']
  },
  currentGovenance: {
    question: '9.2a What best describes the current governance arrangement of the site?',
    options: [
      'Governance by government',
      'Shared governance ',
      'Private governance',
      'Governance by indigenous peoples and local communities',
      'Mixed governance',
      'None',
      'Unknown'
    ]
  },
  changeInTenureArrangement: {
    question:
      '9.3 Has the tenure arrangement of the site changed since the start of the project activities?',
    options: ['Yes', 'No']
  },
  currentLandOwnership: {
    question: '9.3a What is the current land ownership of the site?',
    options: [
      'Private - individual',
      'Private - business',
      'Customary – informal / can be private',
      'Communal',
      'Sub-national or local government',
      'National government',
      'Unknown'
    ]
  },
  rightsToLandInLaw: {
    question: '9.3b Are customary rights to land within the site recognised in national law?',
    options: ['Yes', 'No', 'Partially']
  },
  socioeconomicOutcomes: {
    question: '9.4 What were the socioeconomic outcomes of the project activities at the site?'
  },
  socioeconomicOutcomesAdditionalData: {
    question: '9.4a Please fill the measurement data for the selected socioeconomic outcomes.'
  },
  achievementOfSocioeconomicAims: {
    question: '9.5 To what extent do you feel the socio-economic aims have been achieved?',
    options: [
      'The socio-economic aims were not achieved',
      'The socio-economic aims were partially achieved',
      'The socio-economic aims were mostly achieved',
      'The socio-economic aims were fully achieved'
    ]
  }
}

const ecologicalStatusOutcomes = {
  dateOfEcologicalMonitoring: {
    question: '10.1 What were the dates of the ecological monitoring being reported on?'
  },
  monitoringStartDate: {
    question: '10.1a Monitoring start date'
  },
  monitoringEndDate: {
    question: '10.1b Monitoring end date'
  },
  ecologicalMonitoringStakeholders: {
    question: '10.2 Which stakeholders carried out the ecological monitoring?',
    options: [
      'Local community representatives',
      'Local leaders',
      'Indigenous peoples',
      'Traditionally marginalised or underrepresented groups',
      'Landowners/customary area owners',
      'National, central or federal government',
      'Sub-national, regional or state government',
      'Local or municipal government',
      'Overseas government agencies ',
      'Intergovernmental agencies',
      'Managed area manager/personnel',
      'International or national NGO',
      'Small-scale local NGO',
      'Community based organisations, associations or cooperatives',
      'Industry/Private sector',
      'Academic institute or research facility',
      'Ecotourists',
      'Unknown'
    ]
  },
  mangroveAreaIncrease: {
    question: '10.3 Was there an increase in mangrove area?',
    options: ['Yes', 'No', 'Unknown']
  },
  preAndPostRestorationActivities: {
    question: '10.3a What was the mangrove area pre and post restoration activities at the site? '
  },
  mangroveConditionImprovement: {
    question: '10.4 Was there an improvement in mangrove condition?',
    options: ['Yes', 'No', 'Unknown']
  },
  naturalRegenerationOnSite: {
    question: '10.5 Is natural regeneration apparent, with mangroves establishing at the site?',
    options: ['No', 'Mangroves have established', 'Mangroves have established and grown']
  },
  percentageSurvival: {
    question:
      '10.6 What was the percentage survival of the planted mangrove seedlings or propagules?'
  },
  causeOfLowSurvival: {
    question: '10.6a If survival was low, is the cause known?',
    options: [
      'Location not suitable for any mangroves',
      'Location not suitable for species used ',
      'Competition from invasive species',
      'Damage from pests or wild animals',
      'Barnacle/oyster infestations',
      'Plant diseases',
      'Livestock grazing',
      'Storm damage to mangrove trees and their seedlings ',
      'Extreme climatic events',
      'Erosion due to waves or flooding',
      'Refuse dumped on restoration site',
      'Surrounding land use impacting the site',
      'Exploitation for resources',
      'Original cause of loss/degradation not addressed',
      'Change in governmental/legislative support ',
      'Weak/unsupportive tenure arrangement ',
      'Weak/unsupportive management rights',
      'Weak local natural resource governance institutions',
      'Lack of sustainable financing mechanism in place',
      'Poor stakeholder participation and engagement',
      'Poor benefit distribution',
      'Unknown '
    ]
  },
  mangroveEcologicalOutcomes: {
    question: '10.7 What mangrove ecological outcomes were monitored?'
  },
  mangroveEcologicalOutcomesAdditionalData: {
    question: '10.7a Please fill the measurement data for the selected ecological outcomes.'
  },
  achievementOfEcologicalAims: {
    question: '10.8 To what extent do you feel the ecological aims have been achieved?',
    options: [
      'The ecological aims were not achieved',
      'The ecological aims were partially achieved',
      'The ecological aims were mostly achieved',
      'The ecological aims were fully achieved'
    ]
  }
}

export {
  restorationAims,
  projectDetails,
  siteBackground,
  causesOfDecline,
  preRestorationAssessment,
  siteInterventions,
  costs,
  managementStatusAndEffectiveness,
  socioeconomicGovernanceStatusOutcomes,
  ecologicalStatusOutcomes
}
