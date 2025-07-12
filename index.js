#!/usr/bin/env node

/**
 * PixelPerfect Cross-Platform Image Optimization Suite
 * 
 * This package contains the source code for PixelPerfect apps:
 * - macOS (SwiftUI)
 * - iOS (SwiftUI) 
 * - Android (Jetpack Compose)
 * 
 * @version 1.0.0
 * @author Wader Zhang <wader.zhang@gmail.com>
 */

const fs = require('fs');
const path = require('path');

class PixelPerfectProject {
    constructor() {
        this.version = '1.0.0';
        this.platforms = ['macOS', 'iOS', 'Android'];
        this.projectRoot = __dirname;
    }

    /**
     * Get information about the project
     */
    getProjectInfo() {
        return {
            name: 'PixelPerfect',
            version: this.version,
            platforms: this.platforms,
            description: 'Cross-Platform Image Optimization Suite',
            author: 'Wader Zhang',
            license: 'UNLICENSED'
        };
    }

    /**
     * List available platforms
     */
    listPlatforms() {
        return this.platforms.map(platform => {
            const platformPath = path.join(this.projectRoot, `PixelPerfect ${platform === 'macOS' ? '' : platform}`);
            return {
                platform,
                path: platformPath,
                exists: fs.existsSync(platformPath)
            };
        });
    }

    /**
     * Get build instructions for a platform
     */
    getBuildInstructions(platform) {
        const instructions = {
            'macOS': 'Open PixelPerfect/PixelPerfect.xcodeproj in Xcode and build',
            'iOS': 'Open PixelPerfect iOS/PixelPerfect iOS.xcodeproj in Xcode and build',
            'Android': 'Open PixelPerfect Android/ folder in Android Studio and build'
        };
        
        return instructions[platform] || 'Platform not supported';
    }

    /**
     * Display welcome message
     */
    welcome() {
        console.log(`
🎨 PixelPerfect v${this.version}
Cross-Platform Image Optimization Suite

📱 Available Platforms:
${this.platforms.map(p => `  - ${p}`).join('\n')}

🛠  Build Instructions:
${this.platforms.map(p => `  ${p}: ${this.getBuildInstructions(p)}`).join('\n')}

📚 Documentation: https://github.com/Lihaila/pixelperfect-project
        `);
    }
}

// Export for use as module
module.exports = PixelPerfectProject;

// CLI usage
if (require.main === module) {
    const project = new PixelPerfectProject();
    
    const command = process.argv[2];
    
    switch(command) {
        case 'info':
            console.log(JSON.stringify(project.getProjectInfo(), null, 2));
            break;
        case 'platforms':
            console.log(JSON.stringify(project.listPlatforms(), null, 2));
            break;
        case 'build':
            const platform = process.argv[3];
            if (platform) {
                console.log(project.getBuildInstructions(platform));
            } else {
                console.log('Please specify a platform: macOS, iOS, or Android');
            }
            break;
        default:
            project.welcome();
    }
}
