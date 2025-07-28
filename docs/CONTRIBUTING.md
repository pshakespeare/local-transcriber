# Contributing to Local Video Transcriber

Thank you for your interest in contributing to Local Video Transcriber! This document provides guidelines and information for contributors.

## 🎯 How to Contribute

### Types of Contributions

We welcome contributions in the following areas:

- **Bug Reports**: Report issues and bugs
- **Feature Requests**: Suggest new features
- **Code Contributions**: Submit pull requests
- **Documentation**: Improve or add documentation
- **Testing**: Help with testing and quality assurance

## 🚀 Getting Started

### Prerequisites

1. **Fork the repository** on GitHub
2. **Clone your fork** locally
3. **Set up the development environment**:
   ```bash
   # Install Whisper.cpp
   git clone https://github.com/ggerganov/whisper.cpp.git
   cd whisper.cpp && make
   bash ./models/download-ggml-model.sh base
   
   # Setup project
   export WHISPER_CPP_PATH=/path/to/whisper.cpp
   make setup-quick
   make build
   ```

### Development Workflow

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**:
   - Follow the coding standards
   - Add tests for new functionality
   - Update documentation as needed

3. **Test your changes**:
   ```bash
   make test
   make format
   make lint
   ```

4. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

5. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request** on GitHub

## 📋 Coding Standards

### Python Code

- **Follow PEP 8**: Use consistent formatting
- **Type Hints**: Include type annotations
- **Docstrings**: Document all functions and classes
- **Error Handling**: Implement proper error handling
- **Testing**: Write unit tests for new functionality

### Commit Messages

Use conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:
```
feat(transcriber): add support for VTT output format
fix(docker): resolve permission issues in container
docs(readme): update installation instructions
```

### Code Quality

Before submitting a pull request:

1. **Run tests**:
   ```bash
   make test
   ```

2. **Format code**:
   ```bash
   make format
   ```

3. **Lint code**:
   ```bash
   make lint
   ```

4. **Type checking**:
   ```bash
   make type-check
   ```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
make test

# Run specific test file
pytest tests/test_transcriber.py

# Run with coverage
pytest --cov=transcriber tests/
```

### Writing Tests

- Write tests for new functionality
- Ensure good test coverage
- Use descriptive test names
- Mock external dependencies

## 📚 Documentation

### Documentation Standards

- **README.md**: Keep updated with new features
- **Code Comments**: Add inline comments for complex logic
- **Docstrings**: Document all public functions and classes
- **Examples**: Provide usage examples

### Updating Documentation

When adding new features:

1. Update the main README.md
2. Add examples to QUICK_REFERENCE.md
3. Update relevant sections in other documentation files
4. Add comments to code

## 🐛 Bug Reports

### Before Reporting

1. **Check existing issues** to avoid duplicates
2. **Test with latest version** of the project
3. **Reproduce the issue** consistently

### Bug Report Template

```markdown
**Bug Description**
Brief description of the issue

**Steps to Reproduce**
1. Step 1
2. Step 2
3. Step 3

**Expected Behavior**
What should happen

**Actual Behavior**
What actually happens

**Environment**
- OS: [e.g., Ubuntu 22.04]
- Docker Version: [e.g., 20.10.0]
- Python Version: [e.g., 3.8]
- Whisper.cpp Version: [e.g., latest]

**Additional Information**
Any other relevant information
```

## 💡 Feature Requests

### Feature Request Template

```markdown
**Feature Description**
Brief description of the requested feature

**Use Case**
Why this feature would be useful

**Proposed Implementation**
How you think it could be implemented

**Alternatives Considered**
Other approaches you've considered
```

## 🔧 Development Setup

### Local Development

```bash
# Clone your fork
git clone https://github.com/your-username/local-transcriber.git
cd local-transcriber

# Setup development environment
export WHISPER_CPP_PATH=/path/to/whisper.cpp
make setup-quick
make build

# Start development mode
make dev
```

### Docker Development

```bash
# Build development image
make build

# Run with volume mount for live code changes
docker-compose run --rm -v $(pwd):/app transcriber bash
```

## 📊 Pull Request Process

### Before Submitting

1. **Ensure tests pass**:
   ```bash
   make ci-test
   ```

2. **Update documentation** if needed

3. **Add a description** to your pull request

4. **Link related issues** if applicable

### Pull Request Template

```markdown
**Description**
Brief description of changes

**Type of Change**
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Other (please describe)

**Testing**
- [ ] Tests pass
- [ ] Manual testing completed
- [ ] Documentation updated

**Related Issues**
Closes #(issue number)
```

## 🤝 Code Review

### Review Process

1. **Automated checks** must pass
2. **Code review** by maintainers
3. **Address feedback** and make changes if needed
4. **Maintainer approval** required for merge

### Review Guidelines

- Be constructive and respectful
- Focus on code quality and functionality
- Suggest improvements when possible
- Ask questions if something is unclear

## 📈 Release Process

### Versioning

We use [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, backward compatible

### Release Checklist

- [ ] All tests pass
- [ ] Documentation updated
- [ ] Version bumped
- [ ] Changelog updated
- [ ] Release notes written

## 🆘 Getting Help

### Questions and Support

- **GitHub Issues**: For bug reports and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Documentation**: Check README.md and other docs first

### Communication Guidelines

- Be respectful and inclusive
- Use clear and concise language
- Provide context when asking questions
- Help others when you can

## 📄 License

By contributing to Local Video Transcriber, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Local Video Transcriber! 🎬📝 