xml.features { |xml_features|
  @feature_set.each { |feature|
    xml_features.feature { |xml_feature|
      feature.each { |value|
        xml_feature.value(value)
      }
    }
  }
}
