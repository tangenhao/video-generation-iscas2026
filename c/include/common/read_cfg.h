#pragma once

#include "cfg.h"
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctype.h>
#include <errno.h>
#include <iostream>

namespace common {
namespace read_cfg {

common::cfg::KeyValue* createKeyValue(const char* key)
{
  common::cfg::KeyValue* kv = new common::cfg::KeyValue;
  if (!kv)
    return NULL;
  strcpy(kv->key, key);
  kv->next = NULL;
  return kv;
}

common::cfg::Section* createSection(const char* name)
{
  common::cfg::Section* section = new common::cfg::Section;
  if (!section)
    return NULL;
  strcpy(section->name, name);
  section->keyValues = NULL;
  section->next      = NULL;
  return section;
}

char* trimWhitespace(const char* str)
{
  while (isspace((unsigned char)*str))
    str++;

  if (*str == 0) {
    return strdup("");
  }

  const char* end = str + strlen(str) - 1;
  while (end > str && isspace((unsigned char)*end))
    end--;

  size_t len     = end - str + 1;
  char*  trimmed = reinterpret_cast<char*>(malloc(len + 1));
  if (trimmed) {
    memcpy(trimmed, str, len);
    trimmed[len] = '\0';
  }
  return trimmed;
}

void addKeyValueToSection(common::cfg::Section* section, const char* key, const char* value)
{
  common::cfg::KeyValue* kv = createKeyValue(key);
  if (!kv)
    return;

  char* trimmedKey   = trimWhitespace(key);
  char* trimmedValue = trimWhitespace(value);

  char* endptr;
  errno              = 0;
  kv->value.intValue = strtol(trimmedValue, &endptr, 10);
  if (errno == 0 && *endptr == '\0') {
    kv->type = common::cfg::TYPE_INT;
  }
  else {
    errno                 = 0;
    kv->value.doubleValue = strtod(trimmedValue, &endptr);
    if (errno == 0 && *endptr == '\0') {
      kv->type = common::cfg::TYPE_DOUBLE;
    }
    else {
      kv->type              = common::cfg::TYPE_STRING;
      kv->value.stringValue = trimmedValue;
      trimmedValue          = NULL;
    }
  }

  if (kv->type != common::cfg::TYPE_STRING) {
    free(trimmedValue);
  }

  strcpy(kv->key, trimmedKey);
  free(trimmedKey);

  kv->next           = section->keyValues;
  section->keyValues = kv;
}

common::cfg::Section* addOrUpdateSection(common::cfg::Config* config, const char* sectionName)
{
  common::cfg::Section* current = config->sections;
  while (current) {
    if (strcmp(current->name, sectionName) == 0) {
      return current;
    }
    if (!current->next)
      break;
    current = current->next;
  }

  common::cfg::Section* newSection = createSection(sectionName);
  if (!newSection)
    return NULL;

  if (!current) {
    config->sections = newSection;
  }
  else {
    current->next = newSection;
  }
  return newSection;
}

void parseConfig(const char* filename, common::cfg::Config* config)
{
  FILE* file = fopen(filename, "r");
  if (!file) {
    perror("Error opening file");
    return;
  }

  char                  line[256], sectionName[100] = "";
  common::cfg::Section* currentSection = NULL;

  while (fgets(line, sizeof(line), file)) {
    char* newline = strchr(line, '\n');
    if (newline)
      *newline = '\0';

    if (line[0] == '[') {
      if (sscanf(line, "[%99[^]]]", sectionName) == 1) {
        currentSection = addOrUpdateSection(config, sectionName);
      }
    }
    else if (currentSection) {
      char key[100], value[100];
      if (sscanf(line, "%99[^=]=%99[^\n]", key, value) == 2) {
        addKeyValueToSection(currentSection, key, value);
      }
    }
  }

  fclose(file);
}

void freeConfig(common::cfg::Config* config)
{
  common::cfg::Section* currentSection = config->sections;
  while (currentSection) {
    common::cfg::KeyValue* currentKV = currentSection->keyValues;
    while (currentKV) {
      if (currentKV->type == common::cfg::TYPE_STRING) {
        free(currentKV->value.stringValue);
      }
      common::cfg::KeyValue* nextKV = currentKV->next;
      free(currentKV);
      currentKV = nextKV;
    }
    common::cfg::Section* nextSection = currentSection->next;
    free(currentSection);
    currentSection = nextSection;
  }
  config->sections = NULL;
}
void showConfigFile(const char* configPath)
{
  common::cfg::Config config = {0};
  parseConfig(configPath, &config);

  for (common::cfg::Section* currentSection = config.sections; currentSection; currentSection = currentSection->next) {
    printf("[%s]\n", currentSection->name);
    for (common::cfg::KeyValue* currentKV = currentSection->keyValues; currentKV; currentKV = currentKV->next) {
      printf("%s: ", currentKV->key);
      switch (currentKV->type) {
        case common::cfg::TYPE_INT:
          printf("%d\n", currentKV->value.intValue);
          break;
        case common::cfg::TYPE_DOUBLE:
          printf("%lf\n", currentKV->value.doubleValue);
          break;
        case common::cfg::TYPE_STRING:
          printf("%s\n", currentKV->value.stringValue);
          break;
      }
    }
  }

  freeConfig(&config);
}

int getConfigIntValue(common::cfg::Config* config, const char* sectionName, const char* keyName)
{
  common::cfg::Section* currentSection = config->sections;
  while (currentSection != NULL) {
    if (strcmp(currentSection->name, sectionName) == 0) {
      common::cfg::KeyValue* currentKV = currentSection->keyValues;
      while (currentKV != NULL) {
        if (strcmp(currentKV->key, keyName) == 0 && currentKV->type == common::cfg::TYPE_INT) {
          return currentKV->value.intValue;
        }
        currentKV = currentKV->next;
      }
    }
    currentSection = currentSection->next;
  }
  return -1;
}

}  // namespace read_cfg
}  // namespace common