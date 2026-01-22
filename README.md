# Axiom Action Approval

An on-chain governance system for AI agent action requests on the Stacks blockchain. Axiom Action Approval creates a transparent approval gate where owners review and approve or reject AI agent requests before execution, enabling human-in-the-loop oversight for critical operations.

## Overview

Axiom Action Approval is a Clarity smart contract that implements a structured approval workflow for AI agent actions. It provides owners with complete control over agent operations through an immutable, transparent audit trail while agents submit requests for specific actions requiring approval before execution.

## Features

✓ **Action Request System** - AI agents submit action requests with descriptions for owner review  
✓ **Owner Approval Gate** - Owners approve or reject pending action requests  
✓ **Execution Control** - Agents can only execute approved actions  
✓ **State Tracking** - Tracks approval and execution status for each action  
✓ **Immutable Audit Trail** - All actions timestamped with burn-block-height  
✓ **Role-Based Access Control** - Separate permissions for owners and agents  
✓ **Action Metadata** - Stores owner, agent, description, and status information  

## Contract Functions

### Agent Functions
- `request-action(owner, description)` - Submit action request for owner approval
  - `owner`: Principal address of the owner who will approve
  - `description`: Human-readable action description (max 128 ASCII characters)
  - Returns: Unique action ID on success

- `execute-action(id)` - Execute a previously approved action
  - `id`: Action ID to execute
  - Requires: Owner must have approved the action
  - Requires: Action has not already been executed
  - Returns: Success confirmation

### Owner Functions
- `approve-action(id)` - Approve a pending action request
  - `id`: Action ID to approve
  - Only the action owner can approve
  - Returns: Success confirmation

- `reject-action(id)` - Reject and close a pending action request
  - `id`: Action ID to reject
  - Only the action owner can reject
  - Marks action as executed (prevents future attempts)
  - Returns: Success confirmation

### Read-Only Functions
- `get-action(id)` - Query complete action details
  - Returns: Owner, agent, description, approval status, execution status, creation timestamp

- `action-count` - Get total number of actions created
  - Returns: Next available action ID (total actions created)

## Action Lifecycle
