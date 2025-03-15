class PollutantInfo {
  static const Map<String, Map<String, String>> info = {
    'PM2.5': {
      'title': 'Fine Particulate Matter',
      'description':
          'PM2.5 refers to particulate matter that is 2.5 micrometers or smaller in diameter. These tiny particles can penetrate deep into the lungs and even enter the bloodstream, causing respiratory and cardiovascular issues.',
      'health_effects':
          'Aggravated asthma, decreased lung function, irregular heartbeat, premature death in people with heart or lung disease.',
      'sources':
          'Vehicle emissions, power plants, wood burning, industrial processes and wildfires.',
      'short_term_effects':
          'Irritation of the eyes, nose, and throat, coughing, wheezing, shortness of breath, worsening of existing respiratory conditions.',
      'long_term_effects':
          'Reduced lung function, development of chronic bronchitis, heart disease, and premature death. May contribute to the development of asthma in children.',
      'vulnerable_groups':
          'Children, elderly, people with pre-existing heart or lung diseases, and pregnant women are especially vulnerable to PM2.5 exposure.',
      'natural_sources':
          'Dust storms, forest fires, volcanic eruptions, and sea spray.',
      'human_sources':
          'Combustion from vehicle engines, power plants, wood burning, agricultural burning, and various industrial processes.',
      'guidelines':
          'Annual mean: 5 μg/m³, 24-hour mean: 15 μg/m³ (WHO 2021 guidelines)',
      'monitoring':
          'Measured using specialized filters that capture particles, which are then weighed to determine concentration. Also monitored using light-scattering technology in many modern sensors.',
    },
    'PM10': {
      'title': 'Coarse Particulate Matter',
      'description':
          'PM10 refers to particulate matter that is 10 micrometers or smaller in diameter. These particles are larger than PM2.5 but can still enter the lungs and cause health problems.',
      'health_effects':
          'Irritation of the eyes, nose, and throat, coughing, chest tightness, shortness of breath, reduced lung function.',
      'sources':
          'Dust from construction sites, landfills, agriculture, wildfires and industries.',
      'short_term_effects':
          'Respiratory symptoms like coughing, wheezing, and shortness of breath, aggravation of asthma and other respiratory conditions.',
      'long_term_effects':
          'Reduced lung function growth in children, increased respiratory symptoms, and development of respiratory diseases.',
      'vulnerable_groups':
          'Children, elderly, and people with respiratory conditions such as asthma and COPD.',
      'natural_sources':
          'Dust storms, sea spray, pollen, mold spores, and soil particles lifted by wind.',
      'human_sources':
          'Construction, mining, agriculture, road dust, and industrial activities that involve crushing or grinding operations.',
      'guidelines':
          'Annual mean: 15 μg/m³, 24-hour mean: 45 μg/m³ (WHO 2021 guidelines)',
      'monitoring':
          'Monitored using filtration systems that capture particles, which are then weighed. Some modern sensors use light-scattering techniques for real-time measurements.',
    },
    'O₃': {
      'title': 'Ozone',
      'description':
          'Ground-level ozone is created by chemical reactions between oxides of nitrogen (NOx) and volatile organic compounds (VOCs) in the presence of sunlight. It is a key component of urban smog.',
      'health_effects':
          'Chest pain, coughing, throat irritation, airway inflammation, reduced lung function, and damaged lung tissue.',
      'sources':
          'It is not emitted directly but forms from other pollutants in the presence of sunlight.',
      'short_term_effects':
          'Coughing, throat irritation, pain when taking deep breaths, inflammation of airways, and worsening of respiratory diseases like asthma.',
      'long_term_effects':
          'Permanent lung damage, reduced lung function growth in children, and possibly increased risk of developing asthma.',
      'vulnerable_groups':
          'Children, people with asthma or other respiratory diseases, older adults, and people who are active outdoors.',
      'natural_sources':
          'Small amounts of ozone occur naturally in the atmosphere, but ground-level ozone is primarily from human activities.',
      'human_sources':
          'Forms when pollutants emitted by cars, power plants, industrial boilers, refineries, and chemical plants react in the presence of sunlight.',
      'guidelines': 'Peak season 8-hour mean: 100 μg/m³ (WHO 2021 guidelines)',
      'monitoring':
          'Measured using specialized instruments that detect ozone by its absorption of ultraviolet light or by a chemical reaction that emits light.',
    },
    'NO₂': {
      'title': 'Nitrogen Dioxide',
      'description':
          'NO₂ is a reddish-brown gas with a pungent odor. It primarily gets in the air from burning fuel in vehicles, power plants, and industrial processes.',
      'health_effects':
          'Inflammation of the airways, reduced lung function, increased asthma attacks, and a greater likelihood of respiratory infections.',
      'sources':
          'Vehicles, power plants, industrial emissions and off-road equipment.',
      'short_term_effects':
          'Irritation of airways, increased respiratory symptoms especially in people with asthma, and increased susceptibility to respiratory infections.',
      'long_term_effects':
          'Development of asthma in children, reduced lung function growth, increased susceptibility to respiratory infections, and possibly cardiovascular effects.',
      'vulnerable_groups':
          'People with asthma, children, and older adults with pre-existing respiratory or cardiovascular diseases.',
      'natural_sources':
          'Lightning, volcanic activity, and bacterial processes in soil.',
      'human_sources':
          'Motor vehicle exhaust, electricity generation from fossil fuels, industrial boilers, and other combustion processes.',
      'guidelines':
          'Annual mean: 10 μg/m³, 24-hour mean: 25 μg/m³ (WHO 2021 guidelines)',
      'monitoring':
          'Measured using chemiluminescence, which detects light produced when NO reacts with ozone. Some sensors use electrochemical methods.',
    },
    'SO₂': {
      'title': 'Sulfur Dioxide',
      'description':
          'SO₂ is a colorless gas with a strong odor. It is produced from burning fossil fuels (coal and oil) and from smelting mineral ores that contain sulfur.',
      'health_effects':
          'Irritation of the eyes, nose, and throat, breathing difficulties, and aggravation of respiratory and cardiovascular disease.',
      'sources':
          'Fossil fuel combustion at power plants and industrial facilities, as well as fuel extraction and other industrial processes.',
      'short_term_effects':
          'Bronchoconstriction (narrowing of airways), increased asthma symptoms, and respiratory distress.',
      'long_term_effects':
          'Reduced lung function, increased incidence of respiratory symptoms and diseases, and aggravation of cardiovascular disease.',
      'vulnerable_groups':
          'People with asthma, particularly children, older adults, and those who are active outdoors.',
      'natural_sources':
          'Volcanoes can release significant amounts of SO₂ during eruptions.',
      'human_sources':
          'Burning fossil fuels containing sulfur, especially coal and oil in power plants and industrial facilities. Also produced in metal extraction from ores.',
      'guidelines': '24-hour mean: 40 μg/m³ (WHO 2021 guidelines)',
      'monitoring':
          'Measured using ultraviolet fluorescence spectroscopy, which detects the light emitted when SO₂ molecules are excited by ultraviolet light.',
    },
    'CO': {
      'title': 'Carbon Monoxide',
      'description':
          'CO is a colorless, odorless gas that is produced from the partial oxidation of carbon-containing compounds when there is not enough oxygen to form carbon dioxide.',
      'health_effects':
          'Reduces the amount of oxygen reaching the body\'s organs and tissues, headaches, dizziness, and at high levels can cause death.',
      'sources':
          'Vehicle exhaust, industrial processes, and non-road equipment that burn fossil fuels.',
      'short_term_effects':
          'Headaches, dizziness, confusion, nausea, fainting, and at very high levels, death. CO binds to hemoglobin more readily than oxygen, reducing oxygen delivery to tissues.',
      'long_term_effects':
          'Neurological damage, heart problems, and potential developmental issues in unborn babies when pregnant women are exposed.',
      'vulnerable_groups':
          'People with cardiovascular disease, pregnant women, infants, elderly, and those with chronic obstructive pulmonary disease (COPD).',
      'natural_sources':
          'Volcanic activity, natural gas emissions, and wildfires.',
      'human_sources':
          'Incomplete combustion of fossil fuels in vehicles, boilers, engines, and other combustion equipment. Also comes from household appliances like gas stoves and heaters.',
      'guidelines': 'WHO guidelines: 4 mg/m³ for 24-hour average exposure.',
      'monitoring':
          'Measured using infrared absorption spectroscopy, electrochemical sensors, or gas chromatography techniques.',
    },
  };

  static Map<String, String>? getInfo(String pollutant) {
    return info[pollutant];
  }
}
