---
title: API Reference

language_tabs: # must be one of https://git.io/vQNgJ
  - shell

search: true
---

# Introduction

Welcome to the Angle Health API! This API is used to push and pull information to Angle Health. Use cases include broker integrations and data auditing.  

This documentation is meant to guide you in interacting with Angle Health's API in pushing and pulling member information, information on our benefits plan designs, and group enrollments. 

Angle Health currently offers multiple EPO and PPO medical plans as well as dental and vision. 

Currently we support the API calls listed below. As required, we will evolve our API spec. 

# Authentication

> To obtain your authentication token:

```shell
# With shell, you can just pass the correct header with each request
curl -X POST 
  --header "Content-Type: application/json"
  --header "Authorization: Basic <Base64Encode(<CLIENT_ID>:<CLIENT_SECRET>)>"
  --data '{"auth_type": "client_credentials"}'
  "http://api.anglehealth.com/broker/auth"
```

> Example Response

```json
{
  "access_token": "<ACCESS_TOKEN>",
  "expires_in": 3600000,
  "token_type": "Bearer"
}
```

> Make sure to replace `AUTH_TOKEN` with your authentication token.

Angle Health uses API credentials to authenticate users. When registering with Angle Health, you will be issued a `CLIENT_ID` and `CLIENT_SECRET` pair. Use this to obtain an authentication token which will be used in subsequent calls. Note the authentication token will expire 1 hour after issuing.  

Angle Health expects the authentication token to be included in all API requests to the server in a header that looks like the following:

`Authorization: Basic <AUTH_TOKEN>`

<aside class="notice">
You must replace <code>AUTH_TOKEN</code> with your authentication token in subsequent calls.
</aside>

# Plan Coverage Routes

## Plan Coverage Data
```shell
curl -X POST
 --header "Authorization: Bearer <ACCESS_TOKEN>"
 "http://api.anglehealth.com/broker/plan_metadata"
```

> Body Parameter

```json
{
  "plan_name" : "<PLAN_NAME>"
}
```

> The above command returns the following response:

```json
{
    "plan_name": "<PLAN_NAME>",
    "line_of_coverage": "<LINE_OF_COVERAGE>",
    "effective_date": "<EFFECTIVE_DATE>",
    "end_date": "<END_DATE>",
    "metal_tier": "<METAL_TIER>",
    "rates": "<RATES>"
}
```

This endpoint allows the client to get metadata on any plan that Angle Health offers. This information is used to determine coverage dates, lines of coverage, rates and metal tiers.  


### HTTP Request

`POST http://api.anglehealth.com/broker/plan_metadata`

### Body Parameters

Parameter | Description
--------- |  -----------
plan_name | Name of the plan 
line_of_coverage | Identifies whether the plan is medical, dental, vision
effective_date | Effective start date for the plan 
end_date | End date for the year
metal_tier | Specifies which metal tier the plan falls within
rates | Rate ranges for the plan

# Member Routes

## New Hire Enrollment


```shell
curl -X POST
 --header "Authorization: Bearer <ACCESS_TOKEN>"
 "http://api.anglehealth.com/broker/new_hire_enrollment"
```

> Body Parameter

```json
{
  "lines_of_coverage": {
    "dental": {
      "enrolling_members": [
        {"id": "<ID>",
         "member_type": "employee",
         "plan_name": "delta_dental",
         "group_id": "<GROUP_ID>",
         "employee_start_date": "<MM/DD/YY>"

        },
        {"id": "<ID>",
         "member_type": "dependent",
         "plan_name": "delta_dental",
         "group_id": "<GROUP_ID>",
         "employee_start_date": "<MM/DD/YY>"

        }
      ]
    }, 

    "medical": {
      "enrolling_members": [
        {"id": "<ID>",
         "member_type": "employee",
         "plan_name": "silver_ppo",
         "group_id": "<GROUP_ID>",
         "employee_start_date": "<MM/DD/YY>"
        },
        {"id": "<ID>",
         "member_type": "dependent",
         "plan_name": "bronze_epo",
         "group_id": "<GROUP_ID>",
         "employee_start_date": "<MM/DD/YY>"
        }
      ]
    }
  }
}
```

> The above command returns the following response:

```json
{
  "<ID>": {
    "member_type": "employee",
    "dental": {
      "plan_name": "<PLAN_NAME>",
      "coverage_start_date": "<MM/DD/YY>",
      "coverage_end_date": "<MM/DD/YY>",
      "rate": "<RATE>",
      "parent": "<EMPLOYEE_PARENT_ID>"
    },
    "medical": {
      "plan_name": "<PLAN_NAME>",
      "coverage_start_date": "<MM/DD/YY>",
      "coverage_end_date": "<MM/DD/YY>",
      "rate": "<RATE>",
      "parent": "<EMPLOYEE_PARENT_ID>"
    }
  },
  "<ID>": {
    "member_type": "dependent",
    "dental": {
      "plan_name": "<PLAN_NAME>",
      "coverage_start_date": "<MM/DD/YY>",
      "coverage_end_date": "<MM/DD/YY>",
      "rate": "<RATE>",
      "parent": "<EMPLOYEE_PARENT_ID>"
    },
    "medical": {
      "plan_name": "<PLAN_NAME>",
      "coverage_start_date": "<MM/DD/YY>",
      "coverage_end_date": "<MM/DD/YY>",
      "rate": "<RATE>",
      "parent": "<EMPLOYEE_PARENT_ID>"
    }
  }
}
```

This endpoint allows the broker to push new hire information to Angle Health's systems. Dependents are also pushed via this route. Coverage start and end dates along with the rates are returned. 

<aside class="notice">
Note the id is set by the client that is pushing new hire enrollments. Angle Health will use the id to query member and employee information. 
</aside>

### HTTP Request

`POST http://api.anglehealth.com/broker/new_hire_enrollment`

### Body Parameters

Parameter | Description
--------- |  -----------
id | The id is set and maintained by the client. This will be used to query member information.
member_type | This indicates whether the member is an employee or dependent. 
plan_name | Name of the Angle Health plan
group_id | This is the id of the group in which the member belongs. 

## Termination


```shell
curl -X POST
 --header "Authorization: Bearer <ACCESS_TOKEN>"
 "http://api.anglehealth.com/broker/termination"
```

> Body Parameter

```json
{
  "terminations": [
    {
      "id": "<ID>",
      "last_work_date": "<MM/DD/YYYY>"
    },
    {
      "id": "<ID>",
      "last_work_date": "<MM/DD/YYYY>"
    }
  ]
}
```

> The above command returns the following response:

```json
[
  {
    "id": "<ID>",
    "member_type": "employee",
    "coverage_end_date": "<END_DATE>",
    "parent": "<ID>"
  },
  {
    "id": "<ID>",
    "member_type": "dependent",
    "coverage_end_date": "<END_DATE>",
    "parent": "<EMPLOYEE_PARENT_ID>"
  }
]
```

This endpoint allows the client to update Angle Health's systems if an employee needs to be removed from coverage. The last day of coverage is returned from Angle Health's API to the client. Coverage for all dependents of the employee is also terminated. Coverage end date is returned for each member. 


### HTTP Request

`POST http://api.anglehealth.com/broker/termination`

### Body Parameters

Parameter | Description
--------- |  -----------
id | The id is set and maintained by the client. This will be used to query member information.
last_work_date | This indicates the employee's last work date. 


## Demographic Change


```shell
curl -X POST
 --header "Authorization: Bearer <ACCESS_TOKEN>"
 "http://api.anglehealth.com/broker/demographic_change"
```

> Body Parameter

```json
{
  "member_changes": [
    {
      "id": "<ID>",
      "<key>": "<val>"
    },
    {
      "id": "<ID>",
      "<key>": "<val>"
    }
  ]
}
```

> The above command returns the following response:

```json
{
  "response" : "updated"
}
```

This endpoint allows the client to update Angle Health if an employee or member experiences a demographic change. Angle Health sends a response indicating that the update has been recorded. To track changes, the client should refer to the `member_snapshot` and `group_snapshot` routes. 
 

### HTTP Request

`POST http://api.anglehealth.com/broker/demographic_change`

### Body Schema

Key | Description
--------- |  -----------
id | The id is set and maintained by the client. This will be used to query member information.
name_change | Should be an object with keys `first_name`, `middle_name`, `last_name`, `suffix`.
address_change | Should be an object with keys `home_address`, `mailing_address`
contact_change | Object with keys `home_phone`, `work_phone`, `email_address`, `email_address_type`
ssn_change | New ssn 
dob_change | New dob
sex_change | New sex. One of `F` or `M`
employment_change | `hire_date`, `employment_status`, `occupation`, `hours_worked` are keys to be included 

You may provide multiple keys for each element in the `member_changes` array. They should conform to the schema above. 


## Qualifying Life Events


```shell
curl -X POST
 --header "Authorization: Bearer <ACCESS_TOKEN>"
 "http://api.anglehealth.com/broker/qualifying_life_event"
```

> Body Parameter

```json
{
  "event_type": "<EVENT>",
  "event_date": "<MM/DD/YYYY>",
  "lines_of_coverage": [
    {
      "id": "<ID>",
      "line_of_coverage": "medical",
      "plan_name": "bronze_ppo",
      "coverage_status": "adding_coverage"
    },
    {
      "id": "<ID>",
      "line_of_coverage": "dental",
      "plan_name": "delta_dental",
      "coverage_status": "removing_coverage",
    }
  ]
}
```

> The above command returns the following response:

```json
{ "<ID>": 
{
  "id": "<ID>",
  "coverage_start_date": "<MM/DD/YY>",
  "coverage_end_date": "<MM/DD/YY>",
  "rate": "<RATE>",
  "parent": "<ID>"
},
  "<ID>" : 
  {
    "id": "<ID>",
    "coverage_end_date": "<END_DATE>",
    "parent": "<ID>"
  }
}
```

This endpoint allows the client to update coverage for an employee or dependent due to qualifying life events. Coverage can be added or removed. 
 

### HTTP Request

`POST http://api.anglehealth.com/broker/qualifying_life_event`

### Body Parameters

Key | Description
--------- |  -----------
id | The id is set and maintained by the client. This will be used to query member information.
event_type | A string representing the event type triggering the change in coverage. 
event_date | A date string. This is used to set coverage start and end dates. 
line_of_coverage | Either medical or dental
plan_name | The name of the Angle Health plan for which coverage is changing. 
coverage_status | Should either be `adding_coverage` or `removing coverage`. 

Each element in `lines_of_coverage` must add coverage or remove coverage for a given id. The `event_date` will be used to determine coverage start and end dates as noted in the table above. 

## Open Enrollment

This endpoint allows the client to change coverage for employees and dependents during the open enrollment period. Requests and responses are identical to the qualifying life events route and hence examples are omitted. 

`POST http://api.anglehealth.com/broker/open_enrollment`

<aside class="notice">
You must include open_enrollment as the value for the event_type key. 
</aside>


## Group Enrollment

```shell
curl -X POST
 --header "Authorization: Bearer <ACCESS_TOKEN>"
 "http://api.anglehealth.com/broker/broker/register_group"
```

> Body Parameter

```json
{
  "group_id": "<GROUP_ID>",
  "group_name": "<GROUP_NAME>",
  "group_address": "<GROUP_ADDRESS>",
  "lines_of_coverage": {
    "dental": {
      "enrolling_members": [
        {"id": "<ID>",
         "member_type": "employee",
         "plan_name": "delta_dental"

        },
        {"id": "<ID>",
         "member_type": "dependent",
         "plan_name": "delta_dental"
        }
      ]
    }, 

    "medical": {
      "enrolling_members": [
        {"id": "<ID>",
         "member_type": "employee",
         "plan_name": "silver_ppo"
        },
        {"id": "<ID>",
         "member_type": "dependent",
         "plan_name": "bronze_epo"

        }
      ]
    }
  }
}
```

> The above command returns the following response:

```json
{
  "group_id": "<GROUP_ID>", 
  "member_coverage": [
    {
      "id": "<ID>",
      "member_type": "employee",
      "dental": {
        "plan_name": "<PLAN_NAME>",
        "coverage_start_date": "<MM/DD/YY>",
        "coverage_end_date": "<MM/DD/YY>",
        "rate": "<RATE>",
        "parent": "<EMPLOYEE_PARENT_ID>"
      },
      "medical": {
        "plan_name": "<PLAN_NAME>",
        "coverage_start_date": "<MM/DD/YY>",
        "coverage_end_date": "<MM/DD/YY>",
        "rate": "<RATE>",
        "parent": "<EMPLOYEE_PARENT_ID>"
      }
    },
    {
      "id": "<ID>",
      "member_type": "dependent",
      "dental": {
        "plan_name": "<PLAN_NAME>",
        "coverage_start_date": "<MM/DD/YY>",
        "coverage_end_date": "<MM/DD/YY>",
        "rate": "<RATE>",
        "parent": "<EMPLOYEE_PARENT_ID>"
      },
      "medical": {
        "plan_name": "<PLAN_NAME>",
        "coverage_start_date": "<MM/DD/YY>",
        "coverage_end_date": "<MM/DD/YY>",
        "rate": "<RATE>",
        "parent": "<EMPLOYEE_PARENT_ID>"
      }
    }
  ]
}
```

This endpoint allows the client to enroll employees and dependents from a new group to Angle Health plans.  

### HTTP Request

`POST http://api.anglehealth.com/broker/broker/register_group`

### Body Parameters

Parameter | Description
--------- |  -----------
id | The id is set and maintained by the client. This will be used to query member information.
member_type | This indicates whether the member is an employee or dependent. 
plan_name | Name of the Angle Health plan.
group_name | Name of the group (company).
group_address | Official address of the group.



# Snapshot Routes 

These routes allow the client to capture member and group snapshots. This allows the client to audit transactions and capture data for a group, member or employee at any given point in time. 

## Member Snapshot

```shell
curl -X POST
 --header "Authorization: Bearer <ACCESS_TOKEN>"
 "http://api.anglehealth.com/broker/member_snapshot"
```

> Body Parameter

```json
{
  "id" : "<ID>"
}
```

> The above command returns the following response:

```json
{
    "id": "<ID>",
    "group_id": "<GROUP_ID>",
    "member_type": "employee",
    "first_name": "<FIRST_NAME>",
    "last_name": "<LAST_NAME>",
    "home_address": "<HOME_ADDRESS>",
    "mailing_address": "<MAILING_ADDRESS>",
    "dob": "<DOB>",
    "ssn": "<SSN>",
    "sex": "<sex>",
    "marital_status": "<MARITAL_STATUS>",
    "contact": "<CONTACT>",
    "employment": "<EMPLOYMENT>",
    "medical": "<PLAN_NAME>",
    "dental": "<PLAN_NAME>",
    "vision": "<PLAN_NAME>",
    "parent": "<PARENT_ID>",
    "relationship": "<RELATIONSHIP_TO_PARENT>"
}
```

This endpoint allows the client to get a snapshot of any member. Note the `parent` key links the member to the related employee. The `relationship` key captures the relationship between the member and employee. 


### HTTP Request

`POST http://api.anglehealth.com/broker/member_snapshot`

### Body Parameters

Parameter | Description
--------- |  -----------
id | The id is set and maintained by the client. This will be used to query member information.


## Group Snapshot

```shell
curl -X POST
 --header "Authorization: Bearer <ACCESS_TOKEN>"
 "http://api.anglehealth.com/broker/group_snapshot"
```

> Body Parameter

```json
{
  "group_id" : "<GROUP_ID>"
}
```

> The above command returns the following response:

```json
{
  "members": [
    "<MEMBER_ID>",
    "<MEMBER_ID>"
  ],
  "group_id": "<GROUP_ID>",
  "group_name": "<GROUP_NAME>",
  "group_address": "<GROUP_ADDRESS>"
}

```

This endpoint allows the client to get a snapshot of any group. A group consists of a set of employees and their related dependents who elect for coverage under Angle Health plans. 


### HTTP Request

`POST http://api.anglehealth.com/broker/group_snapshot`

### Body & Response Parameters

Parameter | Description
--------- |  -----------
group_id | The id is set and maintained by the client. This will be used to query group information.
member_id | The id is set and maintained by the client. This will be used to query member information.