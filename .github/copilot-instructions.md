# AI Coding Agent Instructions for `fishmip_2300`

Welcome to the `fishmip_2300` repository! This document provides essential guidelines for AI coding agents to contribute effectively to this project.

## Project Overview

This repository supports the contribution of DBEM (Dynamic Bioclimate Envelope Model) to the FishMIP 2300 projections. FishMIP (Fisheries and Marine Ecosystem Model Intercomparison Project) aims to project the impacts of climate change on marine ecosystems and fisheries.

### Key Components
- **Scripts Directory (`scripts/`)**: Contains scripts for data acquisition and processing.
  - Example: `01_get_data` is a placeholder script for downloading environmental data from the DKRZ server.

## Developer Workflows

### Data Acquisition
- The `scripts/01_get_data` script is used to download environmental data from the DKRZ server.
- Example workflow:
  ```bash
  ssh b381132@levante.dkrz.de
  ```
- Ensure you have the necessary credentials to access the server.

### Adding New Scripts
- Place new scripts in the `scripts/` directory.
- Follow the naming convention: `XX_description` where `XX` is a two-digit number indicating the order of execution.

## Project-Specific Conventions

### File Naming
- Use descriptive names for scripts and files.
- Maintain the `XX_description` format for scripts to ensure clarity and order.

### Documentation
- Add comments to scripts to explain their purpose and usage.
- Update the `README.md` file if new workflows or components are introduced.

## Integration Points

### External Dependencies
- The project relies on data from the DKRZ server. Ensure scripts handle server interactions robustly.

### Cross-Component Communication
- Scripts should be modular and reusable. Avoid hardcoding paths or parameters.

## Examples

### Adding a New Script
1. Create a new script in the `scripts/` directory.
2. Name it following the `XX_description` convention.
3. Document its purpose and usage within the script.

### Updating the `README.md`
- Add a brief description of the new script and its role in the project.

---

For any questions or clarifications, refer to the `README.md` or consult the repository maintainers.