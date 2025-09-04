# Enhanced Project Archive Script Documentation

## Overview

The `archive-project.ps1` script is a sophisticated PowerShell automation tool designed to intelligently archive completed projects to a centralized second brain archive system. It automatically detects the workstation environment, extracts project titles from documentation, and creates organized, searchable archives with comprehensive metadata.

## Key Features

### 🖥️ **Intelligent Workstation Detection**
- Automatically detects different workstation environments
- Configures appropriate archive paths based on hardware
- Supports multiple workstation configurations seamlessly

### 📁 **Smart Project Title Extraction**
- Reads project titles directly from `cursor.md` files
- Ensures consistent naming across archives
- Falls back to directory names if titles aren't found

### 🗂️ **Organized Archive Structure**
- Creates date-based folder hierarchies (YYYY/MM/DD)
- Uses project titles for consistent organization
- Maintains logical file grouping and accessibility

### 📋 **Comprehensive Documentation**
- Generates detailed archive summaries
- Creates project-specific README files
- Preserves all project metadata and context

## Supported Workstations

| Workstation Type | Archive Path | Description |
|------------------|--------------|-------------|
| **AMD 3995wrx** | `F:\secondbrain_v4\secondbrain\secondbrain\4_Archieve\YYYY/MM/DD` | High-performance workstation with dedicated archive drive |
| **Dell XPS** | `C:\projects\secondbrain\YYYY/MM/DD` | Portable workstation with local archive storage |
| **Other/Unknown** | `C:\projects\secondbrain\YYYY/MM/DD` | Fallback configuration for any workstation |

## Prerequisites

### Required Files
- **`cursor.md`**: Must contain project title (usually as `# Project Title`)
- **`archive-project.ps1`**: The archive script itself

### System Requirements
- Windows PowerShell 5.1 or PowerShell Core 6.0+
- Appropriate permissions to create directories and copy files
- Access to the configured archive drive/path

## Usage

### Basic Usage
```powershell
# Navigate to your project directory
cd "C:\path\to\your\project"

# Run the archive script
.\archive-project.ps1
```

### What Happens During Execution

1. **Workstation Detection**
   - Identifies computer name and user
   - Selects appropriate archive base path
   - Displays configuration details

2. **Project Title Extraction**
   - Reads `cursor.md` for project title
   - Extracts title from markdown headers
   - Falls back to directory name if needed

3. **Archive Creation**
   - Creates date-based directory structure
   - Copies all project files (excluding script and cursor.md)
   - Generates comprehensive documentation

4. **Documentation Generation**
   - Creates `ARCHIVE_SUMMARY.md` with full metadata
   - Generates project-specific `README.md`
   - Preserves project context and structure

## Archive Structure

```
Archive Base Path/
└── YYYY/
    └── MM/
        └── DD/
            └── Project Title/
                ├── ARCHIVE_SUMMARY.md
                ├── README.md
                ├── project_file_1.ext
                ├── project_file_2.ext
                └── ... (all other project files)
```

## Generated Files

### ARCHIVE_SUMMARY.md
Contains comprehensive project metadata:
- Project title and identification
- Archive date and location
- Workstation information
- Complete file listing
- Archive benefits and usage instructions

### README.md
Project-specific documentation:
- Project description
- Archive contents overview
- Quick start guide
- Archive details and metadata

## File Exclusion Rules

The script automatically excludes:
- `archive-project.ps1` (the script itself)
- `cursor.md` (project documentation index)

All other files in the project directory are archived.

## Benefits

### 🎯 **Consistency**
- Uniform archive structure across all projects
- Consistent naming based on project titles
- Standardized documentation format

### 🔍 **Searchability**
- Date-based organization for easy time-based searches
- Project title-based folders for content discovery
- Comprehensive metadata for advanced searching

### 📚 **Knowledge Preservation**
- Complete project context preservation
- Detailed documentation of project structure
- Maintains relationships between files and projects

### 🚀 **Efficiency**
- Automated workflow reduces manual errors
- Intelligent path detection saves configuration time
- Comprehensive logging and status reporting

## Error Handling

The script includes robust error handling:
- Validates `cursor.md` existence before proceeding
- Creates archive directories if they don't exist
- Reports success/failure for each file operation
- Provides detailed status information throughout execution

## Customization

### Adding New Workstation Types
To support additional workstation configurations, modify the detection logic:

```powershell
elseif ($ComputerName -like "*NEW_WORKSTATION*") {
    $ArchiveBasePath = "C:\custom\archive\path\$(Get-Date -Format 'yyyy\/MM\/dd')"
    Write-Host "Detected NEW_WORKSTATION - using custom path" -ForegroundColor Green
}
```

### Modifying Archive Paths
Update the `$ArchiveBasePath` variables to match your preferred archive structure.

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| **cursor.md not found** | Ensure cursor.md exists in the project directory |
| **Permission denied** | Run PowerShell as Administrator or check folder permissions |
| **Archive path not accessible** | Verify drive availability and path permissions |
| **Files not copying** | Check if files are locked or in use by other applications |

### Debug Information
The script provides extensive logging:
- Workstation detection details
- Project title extraction results
- File operation status
- Archive creation progress

## Best Practices

1. **Always include cursor.md** with clear project titles
2. **Run from project root directory** for best results
3. **Review generated documentation** for accuracy
4. **Keep archive paths consistent** across workstations
5. **Regularly backup archive locations** for data safety

## Version History

- **Current Version**: Enhanced Project Archive Script
- **Key Improvements**: 
  - Intelligent workstation detection
  - Project title extraction from cursor.md
  - Comprehensive documentation generation
  - Enhanced error handling and logging

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review script output for error messages
3. Verify file permissions and accessibility
4. Ensure all prerequisites are met

---

*This documentation was generated for the Enhanced Project Archive Script (archive-project.ps1)*
