#pragma once

#include <iostream>

namespace common {
namespace cfg {

typedef enum
{
  TYPE_INT,
  TYPE_DOUBLE,
  TYPE_STRING
} ValueType;

typedef union {
  int    intValue;
  double doubleValue;
  char*  stringValue;
} Value;

typedef struct KeyValue {
  char             key[100];
  ValueType        type;
  Value            value;
  struct KeyValue* next;
} KeyValue;

typedef struct Section {
  char            name[100];
  KeyValue*       keyValues;
  struct Section* next;
} Section;

typedef struct {
  Section* sections;
} Config;

}  // namespace cfg
}  // namespace common