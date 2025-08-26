#!/usr/bin/env python3
"""
Script to create GitHub issues from user story markdown files.
Reads user stories and creates corresponding GitHub issues using gh CLI.
"""

import os
import re
import subprocess
import tempfile
import json
from pathlib import Path

def parse_story_file(file_path):
    """Parse a user story markdown file and extract individual stories."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Split content by story sections (US-XXX headers)
    story_pattern = r'^## (US-\d+):\s*(.+?)$'
    sections = re.split(story_pattern, content, flags=re.MULTILINE)
    
    stories = []
    
    # Process sections in groups of 3 (before match, story_id, title, content)
    for i in range(1, len(sections), 3):
        if i + 2 < len(sections):
            story_id = sections[i]
            title = sections[i + 1].strip()
            content = sections[i + 2].strip()
            
            # Extract priority from content
            priority_match = re.search(r'\*\*Priority:\*\*\s*(\w+)', content)
            priority = priority_match.group(1).lower() if priority_match else 'medium'
            
            stories.append({
                'id': story_id,
                'title': title,
                'content': content,
                'priority': priority,
                'full_title': f"{story_id}: {title}"
            })
    
    return stories

def get_priority_label(priority):
    """Convert priority to GitHub label."""
    priority_map = {
        'high': 'high-priority',
        'medium': 'medium-priority',
        'low': 'low-priority'
    }
    return priority_map.get(priority, 'medium-priority')

def create_github_issue(story, repo_name):
    """Create a GitHub issue for a user story."""
    # Create temporary file for issue body
    with tempfile.NamedTemporaryFile(mode='w', suffix='.md', delete=False) as temp_file:
        temp_file.write(story['content'])
        temp_body_path = temp_file.name
    
    try:
        # Prepare labels
        priority_label = get_priority_label(story['priority'])
        labels = f"user-story,mvp,{priority_label}"
        
        # Create GitHub issue using gh CLI
        cmd = [
            'gh', 'issue', 'create',
            '--repo', repo_name,
            '--title', story['full_title'],
            '--body-file', temp_body_path,
            '--label', labels,
            '--milestone', 'MVP v0.1'
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            # Extract issue number from URL
            issue_url = result.stdout.strip()
            issue_number = issue_url.split('/')[-1] if issue_url else 'unknown'
            return {
                'success': True,
                'issue_number': issue_number,
                'url': issue_url
            }
        else:
            return {
                'success': False,
                'error': result.stderr
            }
    
    finally:
        # Clean up temporary file
        if os.path.exists(temp_body_path):
            os.unlink(temp_body_path)

def main():
    """Main function to process all user story files and create GitHub issues."""
    # Configuration
    repo_name = "Amichban/portfolio-x-ray"
    user_stories_dir = Path("/Users/aminechbani/Desktop/cursorProjects/quantx/retail_products/portfolio_x_ray/src/user-stories")
    
    # Story files to process
    story_files = [
        "01-user-management.md",
        "02-data-input-management.md", 
        "03-portfolio-dashboard.md",
        "04-risk-calculations.md",
        "05-concentration-analysis.md"
    ]
    
    created_issues = []
    failed_issues = []
    
    print(f"Creating GitHub issues from user stories in: {user_stories_dir}")
    print(f"Target repository: {repo_name}")
    print("-" * 60)
    
    # Process each story file
    for story_file in story_files:
        file_path = user_stories_dir / story_file
        
        if not file_path.exists():
            print(f"⚠️  Warning: File not found: {file_path}")
            continue
            
        print(f"\n📄 Processing: {story_file}")
        
        try:
            # Parse stories from file
            stories = parse_story_file(file_path)
            print(f"   Found {len(stories)} stories")
            
            # Create GitHub issue for each story
            for story in stories:
                print(f"   Creating issue for {story['id']}: {story['title']}")
                
                result = create_github_issue(story, repo_name)
                
                if result['success']:
                    created_issues.append({
                        'story_id': story['id'],
                        'title': story['title'],
                        'issue_number': result['issue_number'],
                        'url': result['url'],
                        'file': story_file
                    })
                    print(f"   ✅ Created issue #{result['issue_number']}")
                else:
                    failed_issues.append({
                        'story_id': story['id'],
                        'title': story['title'],
                        'error': result['error'],
                        'file': story_file
                    })
                    print(f"   ❌ Failed: {result['error']}")
        
        except Exception as e:
            print(f"   ❌ Error processing {story_file}: {str(e)}")
    
    # Print summary
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    
    print(f"\n✅ Successfully created {len(created_issues)} issues:")
    for issue in created_issues:
        print(f"   • {issue['story_id']}: {issue['title']} (#{issue['issue_number']})")
        print(f"     URL: {issue['url']}")
    
    if failed_issues:
        print(f"\n❌ Failed to create {len(failed_issues)} issues:")
        for issue in failed_issues:
            print(f"   • {issue['story_id']}: {issue['title']}")
            print(f"     Error: {issue['error']}")
    
    print(f"\n📊 Total: {len(created_issues)} created, {len(failed_issues)} failed")
    
    # Save results to JSON file for reference
    results = {
        'created_issues': created_issues,
        'failed_issues': failed_issues,
        'summary': {
            'total_created': len(created_issues),
            'total_failed': len(failed_issues),
            'repo': repo_name
        }
    }
    
    results_file = user_stories_dir.parent / 'github_issues_created.json'
    with open(results_file, 'w') as f:
        json.dump(results, f, indent=2)
    
    print(f"\n📝 Results saved to: {results_file}")

if __name__ == "__main__":
    main()