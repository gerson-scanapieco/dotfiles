---
name: linear-plan
allowed-tools: tidewave(*), linear-server(*), Bash(git:*), sequential-thinking(*), Glob(*), Grep(*), Read(*)
description: Investigate a Linear issue by analysing the issue context and conduting a through codebase investigation to understand the problem and potential resolution paths.
---

## Context

Read the contents of Linear issue $ARGUMENTS and conduct a comprehensive investigation. This includes analyzing parent/sibling issues for context, then thoroughly investigating the codebase to understand the problem domain and identify potential resolution paths.

## Critical Instructions - READ CAREFULLY

**THINK SYSTEMATICALLY**: Use sequential thinking to break down the investigation into logical phases. Take time to understand the problem deeply before jumping into code analysis.

**BE THOROUGH**: Your investigation should e comprehensive enough to understand both the business problem and the technical implementation details needed for resolution.

**FOCUS ON UNDERSTANDING**: The goal is investigation and analysis, not implementation. Understand what exists, what's broken, and what paths forward are available.

**PRESENT BEFORE ACTION**: ALWAYS present your complete investigation summary to the users before performing any write/create actions through MCP tools (Linear comments, Notion updates, etc.). The user must review your findings befpre you proceed with documentation.

## Your Investigation Task

### Phase 1: Issue Context Analysis

- **MANDATORY**: Read the entirety of Linear issue $ARGUMENTS, including project, labels, description, attachments and all comments
- **MANDATORY**: Analyze the issue type (bug, feature, enhancement, etc.) and priority level
- **MANDATORY**: Identify and read any parent issues, sub-issues, and sibling issues for full context
- **MANDATORY**: Analyze any screenshots present in the issue $ARGUMENTS. These screenshots define how the UI must look like
- **MANDATORY**: Extract key technical terms, components names, and system references from the issue
- **MANDATORY**: Identify the affected user journey or business impact

### Phase 2: Codebase Investigation Strategy

- **MANDATORY**: Use sequential thinking to plan the investigation approach based on the issue's context
- **MANDATORY**: Identify the likely affected components/styles/apis based on issue description
- **MANDATORY**: Determine key search terms, function names, file patterns, API endpoints to investigate
- **MANDATORY**: Plan the investigation sequence from high-level architecture down to specific implementations

### Phase 3: Deep Codebase Analysis

- **MANDATORY**: Search for relevant code patterns, functions, and components mentioned in the issue
- **MANDATORY**: Analysize the current implementation of related functionality
- **MANDATORY**: Investigate database schema and data models if applicable
- **MANDATORY**: Review API endpoints related to the issue
- **MANDATORY**: Examine test files to understand expected behaviour
- **MANDATORY**: Look for recent changes or commits related to the problem area
- **MANDATORY**: Identify configuration files and environment variables that may be relevant

### Phase 4: Problem Analysis and Patterns

- **MANDATORY**: Document the current state of the system related to the issue
- **MANDATORY**: Identify the root cause if this is a bug report
- **MANDATORY**: Find similar implementations in the codebase for consistency patterns
- **MANDATORY**: Analyze error handling and edge cases in related code
- **MANDATORY**: Review logging and monitoring capabilities in the affected area
- **MANDATORY**: Assesss the complexity and scope of the issue

### Phase 5: Investigation Report Generation

- **MANDATORY**: Create a comprehensive investigation report with the following sections:
  - **Issue Summary**: Clear problem statement and context
  - **Business Impact**: How this affects users and business processes
  - **Technical Analysis**: Current implementation details and architecture
  - **Root Cause Analysis**: If applicable, what's causing the problem
  - **Code Locations**: Specific files, functions, and line numbers involved
  - **Data Flow**: How data moves through the system for this feature/bug
  - **Dependencies**: What other systems or componentsa are involved
  - **Complexity Assessment**: How complex would a resolution be
  - **Resolution Approaches**: What could go wrong with various approaches
  - **Testing Considerations**: What areas need testing coverage

### Phase 6: Investigation Summary Presentation

- **MANDATORY**: Present a comprehensive investigation summary to the user before performing any write/create actions
- **MANDATORY**: The investigation summry must be written by Claude and include all key findings from the investigation
- **MANDATORY**: The summary must be clearly presented to the user for review before proceeding with any MCP tools actions like adding comments to Linear
- **MANDATORY**: Wait for user acknowledgement or feedback before proceeding with documentation actions

### Phase 7: Documentation and Communications

- **CONDITIONAL**: Only after presenting the investigation summary to the user, proceed with the following:
- **MANDATORY**: Add the complete investigation report as a comment to the Linear issue $ARGUMENTS
- **MANDATORY**: Include specific file paths and line numbers for all code references
- **MANDATORY**: Provide code snippets showing the desired implementation where relevant
- **MANDATORY**: Tag the investigation comment appropriately for easy reference

## Investigation Quality Requirements

Your investigation MUST include:

1. **Specific Code References**: Exact file paths, function names, and line numbers
2. **Current Implementation Analysis**: How the system currently works
3. **Data Flow Documentation**: How data moves through the affected systems
4. **Architecture Context**: How this fits into the overral system design
5. **Similar Patterns**: Other implementations in the codebase for reference
6. **Dependency Mapping**: What other components depende on or are depended upon
7. **Error Scenarios**: How errors are currently handled in this area
8. **Configuration Analysis**: Relevant config files and environment variables
9. **Recent Changes**: Git history analysis for related recent modifications
10. **Test Coverage**: Existing test coverage for the affected functionality

## Investigation Approach

- **START BROAD**: Begin with high-level system understanding
- **NARROW DOWN**: Focus on specific components as your gather information
- **FOLLOW DATA**: Trace how data flows through the system
- **QUESTION ASSUMPTIONS**: Verify your understanding with code evidence
- **DOCUMENT FINDINGS**: Keep detailed notes with specific references
- **THINK LIKE A DETECTIVE**: Follow clues and build a complete picture
- **CONSIDER HISTORY**: Look at git history to understand how we got here
- **ASSESS IMPACT**: Understand the broader implications of any change

## Output Format

Your investigation should result in a detailed report that answers:

- What exactly is the problem or requirement?
- How does the current system work in this area?
- What are the technical components involved?
- What are the possible approaches to the resolution?
- What are the risks and considerations for each approach?
- What would be the scope and complexity of implementation?
- What are the minimal unit and integration tests necessary to assess the work?

Remember: The goal is deep understanding and analysis, not implementation. Your're building the knowledge foundation that will enable effective problem resolution.
